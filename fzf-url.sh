#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan
#    Email: wenxuangm@gmail.com
#  Created: 2018-04-06 12:12
#===============================================================================

fzf_cmd() {
    fzf-tmux -d 35% --multi --exit-0 --cycle --reverse --bind='ctrl-r:toggle-all' --bind='ctrl-s:toggle-sort'
}

if  hash xdg-open &>/dev/null; then
    open_cmd='nohup xdg-open'
elif hash open &>/dev/null; then
    open_cmd='open'
fi

content="$(tmux capture-pane -J -p)"
urls=($(echo "$content" |
  rg -o -N 'https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)'))
wwws=($(echo "$content" |
  rg -o -N -e '(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)' \
           -e '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(:[0-9]{1,5})?(/\S+)*' --replace 'https://$0'))
locals=($(echo "$content" | rg -o -N 'https?://\w+:\w+'))

# Ends up being n log n
containsElement () {
    local e match="$1"
    shift
    for e; do [[ "${e//'https://'}" == "${match//'http://'}" ]] && return 0; done
    return 1
}

merge() {
    local idx=2
    for item in "$@" ; do
        containsElement "$item" "${@:$idx}" || echo "$item"
        idx=$((idx+1))
    done
}

merge "${urls[@]}" "${wwws[@]}" "${locals[@]}" |
    sort -u -f                   |
    nl -w3 -s '  '               |
    fzf_cmd                      |
    awk '{print $2}'             |
    xargs -n1 -I {} $open_cmd {} &>/dev/null ||
    true
