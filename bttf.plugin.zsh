function bttf::log() {
    local prefix="${2:+${1}}"
    local msg="${2:-${1}}"
    echo "[bttf::log]${prefix}:: ${msg}"
}

function bttf::log::error() {
    bttf::log "[error]" "$@"
}

function bttf::check() {
    autoload -Uz is-at-least
    if ! is-at-least 4.3.7; then
        bttf::log::error "Not support zsh version"
        return 1
    fi

    if [[ "$(tput colors)" != "256" ]]; then
        bttf::log::error "Not support color"
        return 1
    fi
}


function bttf::init() {
    bttf::check || return 0
    bttf::init::color
    bttf::init::vcs_info

    precmd_functions+=(bttf::precmd)
}

function bttf::init::color() {
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

function bttf::init::vcs_info() {
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' formats "%F{${default_prompt_git_color}}[%b]%f"
    zstyle ':vcs_info:git:*' actionformats "%F{${default_prompt_git_color}}[%b(%a)]%f"
}

function bttf::precmd() {
    vcs_info
}

function bttf::destination_time() {
    echo -n "%F{${bttf_color_timecircuit_1}}[$(date +%H:%M:%S)]"
}

function bttf::present_time() {
    echo -n "%F{${bttf_color_timecircuit_2}}[$(date +%H:%M:%S)]"
}

function bttf::last_time_departed() {
    echo -n "%F{${bttf_color_timecircuit_3}}[$(date +%H:%M:%S)]"
}

function bttf::prompt_render() {
    local r="$(bttf::rprompt_render)"
    local l="$(bttf::prompt_user)@$(bttf::prompt_dir)"
    local invisible='%([BSUbfksu]|([FK]|){*})'
    local r_w=${(m)#${(S%%)r//$~invisible/}}
    local l_w=${(m)#${(S%%)l//$~invisible/}}
    local w=$((COLUMNS - r_w - l_w))
    if ((w < 1)); then
        printf "%s\n%*s%s\n$" "$l" "$((COLUMNS - r_w))" " " "$r"
    else
        printf "%s%*s%s\n$" "$l" "$w" " " "$r"
    fi
}

function bttf::rprompt_render() {
    local last_rtn="$?"
    if [ ${last_rtn} = "0" ]; then
        echo -n "%F{${bttf_color_timecircuit_3}}(${last_rtn})%f"
    else
        echo -n "%F{${bttf_color_timecircuit_1}}(${last_rtn})%f"
    fi
    bttf::prompt_git
}

function bttf::prompt_symbol() {
  if [ $UID -eq 0 ]; then
    echo -n '#'
  else
    echo -n '$'
  fi
}

function bttf::prompt_user() {
    echo -n "%F{${default_prompt_user_color}}%n%f"
}

function bttf::prompt_dir() {
    echo -n "%F{${default_prompt_dir_color}}%1d%f"
}

function bttf::prompt_git() {
    echo -n "${vcs_info_msg_0_}$(bttf::present_time)%f"
}

function bttf::theme() {
    bttf::init

    setopt prompt_subst
    PROMPT='$(bttf::prompt_render) '
    RPROMPT=''
}

bttf::theme
