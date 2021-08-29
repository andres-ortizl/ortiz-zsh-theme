#!/bin/zsh
# vim:et sts=2 sw=2 ft=zsh

export STATUS_COLOR=cyan
export PWD_COLOR=cyan
export DIRTY_COLOR=yellow
export CLEAN_COLOR=green
export BG_COLOR=''

function _prompt_main() {
  # This runs in a subshell
  RETVAL=${?}

  prompt_status
  prompt_pwd
  prompt_git
  prompt_end
  prompt_cmd_line
}

function prompt_cmd_line(){
  print -n "\n%F{${BG_COLOR}}ツ "
}

function prompt_segment() {
  print -n "%K{${1}}"
  if [[ -n ${BG_COLOR} ]] print -n "%F{${BG_COLOR}}%k"
  print -n "${2}"
  BG_COLOR=${1}
}

function prompt_standout_segment() {

  print -n "%S%F{${1}}"
  code=155
  #print -n "%F{$code}Color%f"
  if [[ -n ${BG_COLOR} ]] print -n "%K{${BG_COLOR}}%k"
  print -n "${2}%s"
  BG_COLOR=${1}
}

function preexec() {
  timer=$(date +%s%3N)
}

function prompt_end() {
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
      prompt_standout_segment ${PWD_COLOR} "${elapsed}"
      unset timer
    fi
}
# for code in {000..255}; do print -P -- "$code: %F{$code}Color%f"; done

function prompt_status() {
  local segment=''
  if (( RETVAL )) segment+=' %F{red}✘'
  if (( EUID == 0 )) segment+=' %F{yellow}⚡'
  if (( $(jobs -l | wc -l) )) segment+=' %F{cyan}⚙'
  if (( RANGER_LEVEL )) segment+=' %F{cyan}r'
  if [[ -n ${VIRTUAL_ENV} ]] segment+=" %F{cyan}${VIRTUAL_ENV:t} 🐍"
  if [[ -n ${SSH_TTY} ]] segment+=" %F{%(!.yellow.default)}%n@%m"
  if [[ -n ${segment} ]]; then
    prompt_segment ${STATUS_COLOR} "${segment} "
  fi
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
    prompt_standout_segment ${git_color} " ${(e)git_info[prompt]}${git_dirty} "
  fi
}

VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

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

PS1='$(_prompt_main)'
unset RPS1
