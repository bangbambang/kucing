FG_G_N="%{$fg[green]%}"
FG_Y_N="%{$fg[yellow]%}"
FG_R_N="%{$fg[red]%}"
FG_W_N="%{$fg[white]%}"
FG_G_B="%{$fg_bold[green]%}"
FG_R_B="%{$fg_bold[red]%}"
R="%{$reset_color%}"
BG_G="%{$bg[green]%}"
BG_R="%{$bg[red]%}"

OK="$FG_G_B›$R"
FAIL="$FG_R_B›$R"

GIT_DIRTY="$FG_R_B⬢$R"
GIT_CLEAN="$FG_G_B⬢$R"
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
      color=$FG_R_N
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m"
      color=$FG_W_N
    else
      commit_age="${minutes}m"
      color=$FG_G_N
    fi
    echo "$color$commit_age%{$reset_color%}"
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
    echo "$FG_G_B %B=%b"
  elif [[ $ours == $yours ]]; then
      echo "$FG_G_N %B+%b"
  elif [[ $ours == $mine ]]; then
    echo "$FG_Y_N %B-%b"
  else
    echo "$FG_R_B %B!%b"
  fi
}

gitprompt() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "$(uptodate)$(current_branch)$R :: $(last_commit) :: $(local_status)"
  fi
}


PROMPT=" $FG_Y_N%2~ $R%(?.$OK.$FAIL) "
RPROMPT="$(gitprompt)"
