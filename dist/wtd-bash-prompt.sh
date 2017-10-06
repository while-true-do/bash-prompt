#!/bin/bash
#
# Are we in Bash?
[ -n "$BASH_VERSION" ] || return 0
# Are we interactive?
[[ $- == *i* ]] || return 0

# Which OS do we use?
if grep -q -i fedora /etc/os-release ;then
  WTD_GIT_PROMPT_PATH="/usr/share/git-core/contrib/completion/git-prompt.sh"
elif grep -q -i debian /etc/os-release ; then
  WTD_GIT_PROMPT_PATH="/etc/bash_completion.d/git-prompt"
elif grep -q -i suse /etc/os-release ; then
  WTD_GIT_PROMPT_PATH="/etc/bash_completion.d/git-prompt.sh"
elif grep -q -i archlinux /etc/os-release ; then
  WTD_GIT_PROMPT_PATH="/usr/share/git/git-prompt.sh"
fi

# Colored Prompt
if [[ $TERM == vte* ]] || [[ $TERM == xterm* ]]; then
  # Define some colors
  WTD_COLOR_USER="\[\e[0;32m\]"
  WTD_COLOR_ROOT="\[\e[0;31m\]"
  WTD_COLOR_SYS="\[\e[0;31m\]"
  WTD_COLOR_AT="\[\e[0m\]"
  WTD_COLOR_HOST="\[\e[0m\]"
  WTD_COLOR_PWD="\[\e[0m\]"
  WTD_COLOR_GIT="\[\e[0;36m\]"
  WTD_COLOR_END="\[\e[0m\]"
  WTD_COLOR_OFF="\[\e[0m\]"
  # Error Notification
  WTD_PS1_B='`LAST_EXIT=$?; if [ $LAST_EXIT != 148 ] && [ $LAST_EXIT != 0 ]; then echo "\[\e[1;31m\]✘ "; fi`'
  # Job Notification
  WTD_PS1_B+='`if [ $(jobs | wc -l) -ne 0 ]; then echo -n "\[\e[1;33m\]⚙\j "; fi`'
  # User Colors
  if [ $EUID -eq 0 ]; then
    WTD_PS1_B+="$WTD_COLOR_ROOT\u"
  elif [ $EUID -lt 1000 ]; then
    WTD_PS1_B+="$WTD_COLOR_SYS\u"
  else
    WTD_PS1_B+="$WTD_COLOR_USER\u"
  fi
  # Only show host, if connected via ssh
  if [ ! -z "$SSH_CLIENT" ]; then
    WTD_PS1_B+="$WTD_COLOR_AT@$WTD_COLOR_HOST\h"
  fi

  # Path
  WTD_PS1_B+=" $WTD_COLOR_PWD"
  WTD_PS1_B+='\w'
  WTD_PS1_B+="$WTD_COLOR_OFF "
  # End
  WTD_PS1_E="$WTD_COLOR_END\\$ $WTD_COLOR_OFF"
else
  # Uncolored alternative
  # Error Notification
  WTD_PS1_B='`LAST_EXIT=$?; if [ $LAST_EXIT != 148 ] && [ $LAST_EXIT != 0 ]; then echo "✘ "; fi`'
  # Job Notification
  WTD_PS1_B+='`if [ $(jobs | wc -l) -ne 0 ]; then echo "⚙\j "; fi`'
  # Prompt
  WTD_PS1_B+="\u@"
  if [ ! -z "$SSH_CLIENT" ]; then
    WTD_PS1_B+="\h "
  fi
  WTD_PS1_B+="\w "
  WTD_PS1_E="\\$ "
fi
# Source the git Prompt and set some options
if [ -e "$WTD_GIT_PROMPT_PATH" ]; then
  export GIT_PS1_SHOWDIRTYSTATE=true
  export GIT_PS1_SHOWSTASHSTATE=true
  export GIT_PS1_SHOWUNTRACKEDFILES=true
  export GIT_PS1_SHOWUPSTREAM="auto"

  source $WTD_GIT_PROMPT_PATH

  PS1="$WTD_PS1_B"
  PS1+="$WTD_COLOR_GIT"
  PS1+='$(__git_ps1 "(%s) ")'
  PS1+="$WTD_PS1_E"
else
  PS1="$WTD_PS1_B$WTD_PS1_E"
fi
