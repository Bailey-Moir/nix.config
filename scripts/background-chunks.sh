#!/usr/bin/env bash
lastName=""
f() {
    name=$(jq -r ".name" /etc/nixos/hosts/$(hostname)/theme.json 2>/dev/null || echo "")
    [[ "$name" == "$lastName" || "$name" == "" ]] && return
    lastName=$name

    chunks="["
    i=0
    for bg in $(ls ~/.config/bgs/$name); do
        if [ $i -eq 0 ]; then
            chunks+="["
        fi
        chunks+="\"${bg:1}\""
        if [ $i -eq 2 ]; then
            chunks+="]"
            i=0
        else
            ((i++))
        fi
        chunks+=","
    done

    chunks="${chunks%?}]" # remove last character (,), and add ]
    if [ $i -ne 0 ]; then
        chunks+="]"
    fi

    echo $chunks
}

f
while true; do
    inotifywait -qq /etc/nixos/hosts/$(hostname)/theme.json
    f
done
