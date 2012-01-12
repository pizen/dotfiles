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

PS1="[$YELLOW\d \t $LIGHT_GRAY\u@\h:$LIGHT_GREEN\w$LIGHT_GRAY]\n$LIGHT_PURPLE\$(parse_git_branch)$LIGHT_GRAY> "

export CLICOLOR=true

EDITOR=vim

# History configuration
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
