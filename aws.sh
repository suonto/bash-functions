#!/bin/zsh

# Supported Colors: red , blue , green , cyan , yellow , magenta , black , & white
autoload -U colors && colors
autoload -U compinit && compinit

function _aws_prompt_info() {
  if [[ "$AWS_PROFILE" == "default" || -z $AWS_PROFILE ]]; then
    echo "%{$fg[cyan]%}${ZSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE:=default(unset)}${ZSH_THEME_AWS_SUFFIX:=>}%{$reset_color%}"
  elif [[ "$AWS_PROFILE" == "mycorp"* ]]; then
    echo "%{$fg[yellow]%}${ZSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE}${ZSH_THEME_AWS_SUFFIX:=>}%{$reset_color%}"
  else
    echo "%{$fg[red]%}${ZSH_THEME_AWS_PREFIX:=<aws:}${AWS_PROFILE:=default}${ZSH_THEME_AWS_SUFFIX:=>}%{$reset_color%}"
  fi
}

if [[ "$SHOW_AWS_PROMPT" != false && "$RPROMPT" != *'$(_aws_prompt_info)'* ]]; then
  RPROMPT='$(_aws_prompt_info)'"$RPROMPT"
fi

function _awsp() {
  local state

  _arguments \
    '1: :->aws_profile'

  case $state in
    (aws_profile) _arguments '1:profiles:($(cat ~/.aws/config | grep "\[" | sed "s/profile\ //; s/\[//; s/\]//" | sort))' ;;
  esac
}


function awsp() {
  local profiles=$(cat ~/.aws/config | grep '\[' | sed 's/profile\ //; s/\[//; s/\]//' | sort)

  if [[ "$1" != "" ]]; then
    if [[ $(echo $profiles | grep -c "$1") -eq 0 ]]; then
      echo "Profile '$1' not found in ~/.aws/config" >&2
    else
      export AWS_PROFILE="$1"
    fi
  else
    echo $profiles
  fi
}

compdef _awsp awsp
