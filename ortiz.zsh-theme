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

function preexec() {
  # executed every time we run a command
  timer=$(date +%s%3N)
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
  # elapsed cmd time
    if [ $timer ]; then
      local now=$(date +%s%3N)
      local d_ms=$(($now-$timer))
      local d_s=$((d_ms / 1000))
      local ms=$((d_ms % 1000))
      local s=$((d_s % 60))
      local m=$(((d_s / 60) % 60))
      local h=$((d_s / 3600))
      if ((h > 0)); then elapsed=${h}h${m}m
      elif ((m > 0)); then elapsed=${m}m${s}s
      elif ((s >= 10)); then elapsed=${s}.$((ms / 100))s
      elif ((s > 0)); then elapsed=${s}.$((ms / 10))s
      else elapsed=${ms}ms
      fi
      prompt_standout_segment ${PWD_COLOR} " ${elapsed}"
      unset timer
    fi

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
PS1='$(_prompt_main)' # left side of the terminal
unset RPS1
