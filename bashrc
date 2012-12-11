function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
YELLOW="\[\033[0;33m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
LIGHT_PURPLE="\[\033[1;34m\]"

if [ -n "$SSH_CLIENT" ]; then
    HN_COLOR=$LIGHT_RED
else
    HN_COLOR=$LIGHT_GRAY
fi


PS1="[$YELLOW\d \t $WHITE\u$LIGHT_GRAY@$HN_COLOR\h$LIGHT_GRAY:$LIGHT_GREEN\w$LIGHT_GRAY]\n$LIGHT_PURPLE\$(parse_git_branch)$LIGHT_GRAY> "

export CLICOLOR=true

EDITOR=vim

# History configuration
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

UNAME=`uname`
if [ "$UNAME" == "Linux" ]; then
    alias ls='ls --color=auto'
fi
     
if [ "$UNAME" == "Darwin" ]; then
    export TERM=xterm-color
    alias ls='ls -G'
fi
