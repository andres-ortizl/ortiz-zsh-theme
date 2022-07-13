#!/bin/zsh

# available colors in print_available_colors
export STATUS_COLOR=140
export PWD_COLOR=140
export DIRTY_COLOR=220
export CLEAN_COLOR=191
export SEP='%F{051} \u00A6' # https://en.wikipedia.org/wiki/List_of_Unicode_characters
export FULL_PATH_VIRTUAL_ENV=0
export KUBERNETES_COLOR_PROMPT=033

function _prompt_main() {
  # This runs in a subshell
  RETVAL=${?}
  prompt_status
  prompt_pwd
  prompt_git
  prompt_time
  prompt_cmd_line
}


function prompt_pwd() {
  local current_dir=${(%):-%~}
  if [[ ${current_dir} != '~' ]]; then
    current_dir="${${(@j:/:M)${(@s:/:)current_dir:h}#?}%/}/${current_dir:t}"
  fi
  prompt_standout_segment ${PWD_COLOR} " ${current_dir}"
}

function prompt_git() {
  if [[ -n ${git_info} ]]; then
    local git_color
    local git_dirty=${(e)git_info[dirty]}
    if [[ -n ${git_dirty} ]]; then
      git_color=${DIRTY_COLOR}
    else
      git_color=${CLEAN_COLOR}
    fi
    prompt_standout_segment ${git_color} " ${(e)git_info[prompt]}${git_dirty}"
  fi
}



function prompt_status() {
  local segment=''
  if (( RETVAL )) segment+=' %F{red}✘ ' # failed cmd
  if (( EUID == 0 )) segment+=' %F{yellow}⚡ ' # sudo user
  if (( $(jobs -l | wc -l) )) segment+=' %F{cyan}⚙ ' # jobs pending
  if (( RANGER_LEVEL )) segment+=' %F{cyan}r'
  if [[ -n ${VIRTUAL_ENV} ]] && [[ ${FULL_PATH_VIRTUAL_ENV} = 1 ]] segment+="%F{cyan}${VIRTUAL_ENV:t}${SEP}" # virtualenv
  if [[ -n ${VIRTUAL_ENV} ]] && [[ ${FULL_PATH_VIRTUAL_ENV} = 0 ]] segment+="%F{cyan}🐍${SEP}" # virtualenv
  if [[ -n ${SSH_TTY} ]] segment+=" %F{%(!.yellow.default)}%n@%m"
  if [[ -n ${KUBECONFIG} ]] segment+="%F{$KUBERNETES_COLOR_PROMPT} \u2388 `kubectx -c` \u0488 `kubens -c`${SEP}" # kubernetes ctx
  if [[ -n ${segment} ]]; then
    prompt_standout_segment ${STATUS_COLOR} "${segment}"
  fi
}

function prompt_time() {
  prompt_standout_segment ${PWD_COLOR} " ${duration_info} "
}

function prompt_standout_segment() {
  print -n  "%F{$1}$2%f"

}


function prompt_end(){
  RETVAL=${?}

}
function print_available_colors(){
  for code in {000..255}; do print -P -- "$code: %F{$code}Color%f"; done
}

function prompt_cmd_line(){
  #ツ
  print -n "\n%F{${STATUS_COLOR}}⟫ "

}

if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info:branch' format ' %b'
  zstyle ':zim:git-info:commit' format '➦ %c'
  zstyle ':zim:git-info:action' format ' (%s)'
  zstyle ':zim:git-info:dirty' format ' ±'
  zstyle ':zim:git-info:keys' format \
      'prompt' '%b%c%s' \
      'dirty' '%D'

  autoload -Uz add-zsh-hook && add-zsh-hook precmd git-info
fi

VIRTUAL_ENV_DISABLE_PROMPT=1


#RPROMPT='$(prompt_end)' # Right side of the terminal
setopt nopromptbang prompt{cr,percent,sp,subst}

zstyle ':zim:duration-info' threshold 0.1
zstyle ':zim:duration-info' format '%d '
zstyle ':zim:duration-info' show-milliseconds yes

autoload -Uz add-zsh-hook
add-zsh-hook preexec duration-info-preexec
add-zsh-hook precmd duration-info-precmd
PS1='$(_prompt_main)' # left side of the terminal
unset RPS1
