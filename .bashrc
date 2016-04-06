RED="\[\e[00;31m\]"
GREEN="\[\e[00;32m\]"
YELLOW="\[\e[00;33m\]"
CYAN="\[\e[00;36m\]"
WHITE="\[\e[00;37m\]"
RESET="\[\e[0m\]"

git_status() {
    STATUS=$(git status 2> /dev/null )

    if [[ ${STATUS} =~ "Changes to be committed" ]]
    then
        GSTATUS="${GSTATUS}${GREEN}•${RESET}"
    fi

    if [[ ${STATUS} =~ "Untracked" ]] || [[ ${STATUS} =~ "Changes not staged for commit" ]]
    then
        GSTATUS="${GSTATUS}${RED}×${RESET}"
    fi

    if [[ -z ${GSTATUS} ]]
    then
        echo ""
    else
        echo " ${GSTATUS}"
    fi
}

git_branch() {
    if [[ -d .git ]] || git rev-parse --git-dir > /dev/null 2>&1
    then
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null) 
        echo "${WHITE} (${BRANCH})${RESET}$(git_status)"
    fi
}

tid() {
    echo "[\t"]
}

user_and_host() {
    echo "${GREEN}\u${RESET}${CWHITE}@${RESET}${GREEN}\h${RESET}"
}

colon_seperator() {
    echo "${CWHITE}:${RESET}"
}

working_dir() {
    echo "[${CYAN}\w${RESET}]"
}

divider() {
    echo "${WHITE}❯${RESET}"
}

make_dat_ps1() {
    PS1="$(tid) $(user_and_host)$(working_dir)$(git_branch) $(divider) "
}

export CLICOLOR=1
export EDITOR=vim
export PROMPT_COMMAND=make_dat_ps1
export PATH=$PATH:/usr/local/bin:$HOME/checkout/arcanist/bin
. ~/.aliases
. ~/.func
# Source variables you do not want version controlled
if [ -f ~/.boffline ]
then
    . ~/.boffline
fi
