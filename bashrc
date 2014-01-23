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
GIT_EDITOR=$EDITOR

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

###
# Make deep directory traversal easier
# From http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
###
export MARKPATH=$HOME/.marks
function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark {
    rm -i "$MARKPATH/$1"
}
if [ "$UNAME" == "Linux" ]; then
    function marks {
        ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
    }

    function _completemarks() {
        local curw=${COMP_WORDS[COMP_CWORD]}
        local wordlist=$(find $MARKPATH -type l -printf "%f\n")
        COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
        return 0
    }

    complete -F _completemarks jump unmark
fi

if [ "$UNAME" == "Darwin" ]; then
    function marks {
            \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
    }

    function _completemarks {
        local cur=${COMP_WORDS[COMP_CWORD]}
        local marks=$(find $MARKPATH -type l | awk -F '/' '{print $NF}')
        COMPREPLY=($(compgen -W '${marks[@]}' -- "$cur"))
        return 0
    }
    complete -o default -o nospace -F _completemarks jump unmark
fi
