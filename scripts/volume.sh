#!/usr/bin/env bash
f() {
    if [ "$(pamixer --get-mute)" = true ]; then
        echo -1;
    else 
        pamixer --get-volume 
    fi
}

prev=$(f)
echo "$prev"

pactl subscribe | while read -r _; do
    cur=$(f)
    if [ "$cur" != "$prev" ]; then
        echo "$cur"
        prev="$cur"
    fi
done
