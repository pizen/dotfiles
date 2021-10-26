function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function aws_profile {
  if [ ! -z $AWS_PROFILE ]; then
    echo -n "{$AWS_PROFILE} "
  fi
}

# Case-insensitive globbing
setopt NO_CASE_GLOB

# Automatically add cd
setopt AUTO_CD

# History file
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history

# Add timestamps and stuff
setopt EXTENDED_HISTORY

# Limit history size
SAVEHIST=2000
HISTSIZE=1000

# Share the history between shells
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Tidy up the history
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Enable correction
setopt CORRECT
setopt CORRECT_ALL

UNAME=`uname`
if [ "$UNAME" = "Linux" ]; then
    alias ls='ls --color=auto'
fi

if [ "$UNAME" = "Darwin" ]; then
    alias ls='ls -G'
fi

# vim4lyfe
EDITOR=vim
GIT_EDITOR=$EDITOR

# Do prompt substitution
setopt PROMPT_SUBST

# Set the prompt
# [<last command ret code> <datetime> <user>@<hostname>:<pwd>]
# (git branch)>
PS1='[%(?.%F{green}^-^.%F{red}O_O) %F{yellow}%D{%a %b %d %H:%M:%S} %f%n@%m:%F{green}%~%f]
%F{cyan}$(aws_profile)%F{magenta}$(parse_git_branch)%f$ '

###
# Make deep directory traversal easier
# From http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
# 2013-09-06 Update: Code available as "jump" plugin in oh-my-zsh
#
# I don't want to install full oh-my-zsh just for getting the updated zsh version of this utility so
# just including it inline below.
###
# https://github.com/ohmyzsh/ohmyzsh/blob/master/LICENSE.txt
#
# MIT License
#
# Copyright (c) 2009-2020 Robby Russell and contributors (https://github.com/ohmyzsh/ohmyzsh/contributors)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###
# Easily jump around the file system by manually adding marks
# marks are stored as symbolic links in the directory $MARKPATH (default $HOME/.marks)
#
# jump FOO: jump to a mark named FOO
# mark FOO: create a mark named FOO
# unmark FOO: delete a mark
# marks: lists all marks
###
export MARKPATH=$HOME/.marks

jump() {
	builtin cd -P "$MARKPATH/$1" 2>/dev/null || {echo "No such mark: $1"; return 1}
}

mark() {
	if [[ $# -eq 0 || "$1" = "." ]]; then
		MARK=${PWD:t}
	else
		MARK="$1"
	fi
	if read -q "?Mark $PWD as ${MARK}? (y/n) "; then
		command mkdir -p "$MARKPATH"
		command ln -sfn "$PWD" "$MARKPATH/$MARK"
	fi
}

unmark() {
	LANG= command rm -i "$MARKPATH/$1"
}

marks() {
	local link max=0
	for link in $MARKPATH/{,.}*(@N); do
		if [[ ${#link:t} -gt $max ]]; then
			max=${#link:t}
		fi
	done
	local printf_markname_template="$(printf -- "%%%us " "$max")"
	for link in $MARKPATH/{,.}*(@N); do
		local markname="$fg[cyan]${link:t}$reset_color"
		local markpath="$fg[blue]$(readlink $link)$reset_color"
		printf -- "$printf_markname_template" "$markname"
		printf -- "-> %s\n" "$markpath"
	done
}

_completemarks() {
	reply=("${MARKPATH}"/{,.}*(@N:t))
}
compctl -K _completemarks jump
compctl -K _completemarks unmark

_mark_expansion() {
	setopt localoptions extendedglob
	autoload -U modify-current-argument
	modify-current-argument '$(readlink "$MARKPATH/$ARG" || echo "$ARG")'
}
zle -N _mark_expansion
bindkey "^g" _mark_expansion
