function bttf:log() {
    echo "[bttf:log]$@"
}
function bttf:log:error() {
    bttf:log "[error] $@"
}

function bttf:check() {
    autoload -Uz is-at-least
    if ! is-at-least 4.3.7; then
        bttf:log:error "Not support zsh version"
        exit 1
    fi

    if [[ "$TERM" != *"256color" ]]; then
        bttf:log:error "Not support color"
        exit 1
    fi
}

function bttf:init() {
    bttf:check
    bttf:init:color
    bttf:init:vcs_info

    precmd_functions+=(bttf:precmd)
}

function bttf:init:color() {
    bttf_color_red=160
    bttf_color_green=046
    bttf_color_yellow=226

    bttf_color_timecircuit_1=${bttf_color_red}
    bttf_color_timecircuit_2=${bttf_color_green}
    bttf_color_timecircuit_3=${bttf_color_yellow}

    bttf_color_title_logo_1=124
    bttf_color_title_logo_2=202

    bttf_color_title_logo_strok_1=007
    bttf_color_title_logo_strok_2=015

    default_prompt_user_color=${bttf_color_title_logo_1}
    default_prompt_dir_color=${bttf_color_title_logo_2}
    default_prompt_git_color=${bttf_color_timecircuit_2}
}

function bttf:init:vcs_info() {
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' formats "%F{${default_prompt_git_color}}[%b]%f"
    zstyle ':vcs_info:git:*' actionformats "%F{${default_prompt_git_color}}[%b(%a)]%f"
}

function bttf:precmd() {
    vcs_info
}

function bttf:prompt_render() {
    bttf:prompt_user
    echo -n '@'
    bttf:prompt_dir
    echo -n "$(bttf:prompt_symbol)"
}

function bttf:rprompt_render() {
    bttf:prompt_git
}

function bttf:prompt_symbol() {
  if [ $UID -eq 0 ]; then
    echo -n '#'
  else
    echo -n '$'
  fi
}

function bttf:prompt_user() {
    echo -n "%F{${default_prompt_user_color}}%n%f"
}

function bttf:prompt_dir() {
    echo -n "%F{${default_prompt_dir_color}}%1d%f"
}

function bttf:prompt_git() {
    echo -n "${vcs_info_msg_0_}"
}

function bttf:theme() {
    bttf:init

    setopt prompt_subst
    PROMPT='$(bttf:prompt_render) '
    RPROMPT='$(bttf:rprompt_render)'
}

bttf:theme

