OK="%F{green}%B›%b%f"
FAIL="$%F{red}%B›%b%f"
MODE_N="%F{green}%Bn%b%f"
MODE_I="$%F{red}%Bi%b%f"

GIT_DIRTY="%F{yellow}⬢%f"
GIT_CLEAN="%F{green}⬢%f"
GIT_REBASE="\uE0A0"
GIT_UNPULLED="⇣"
GIT_UNPUSHED="⇡"

last_commit() {
  if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
    # Get the last commit.
    last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now=$(date +%s)
    seconds_since_last_commit=$((now-last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit/3600))

    # Sub-hours and sub-minutes
    days=$((seconds_since_last_commit / 86400))
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))

    if [ $hours -gt 24 ]; then
      commit_age="${days}d"
      color="red"
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m"
      color="yellow"
    else
      commit_age="${minutes}m"
      color="green"
    fi
    echo "%F{$color}$commit_age%f"
  fi
}

current_branch() {
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo $ref
}

local_status() {
  if test -z "$(git status --porcelain --ignore-submodules)"; then
    echo $GIT_CLEAN
  else
    echo $GIT_DIRTY
  fi
}

# taken from http://stackoverflow.com/a/3278427/346626
uptodate() {
  mine=$(git rev-parse @ 2>&1)
  yours=$(git rev-parse @{u} 2>&1)
  ours=$(git merge-base @ @{u} 2>&1)

  if [[ $mine == $yours ]]; then
    echo "%F{green}%B=%b%f"
  elif [[ $ours == $yours ]]; then
      echo "%F{green}${GIT_UNPUSHED}%f"
  elif [[ $ours == $mine ]]; then
    echo "%F{yellow}${GIT_UNPULLED}%f"
  else
    echo "%F{red}%B!%b%f"
  fi
}

gitprompt() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "$(uptodate) $(current_branch)$R :: $(last_commit) :: $(local_status)"
  fi
}

function zle-line-init zle-keymap-select {
    PROMPT="%F{yellow}%2~%f ${${KEYMAP/vicmd/${MODE_N}}/(main|viins)/${MODE_I}}%(?.$OK.$FAIL) "
    RPROMPT="$(gitprompt)"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
