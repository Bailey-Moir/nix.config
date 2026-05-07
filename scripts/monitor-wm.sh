#!/usr/bin/env bash
wmmsg=~/.config/scripts/wm-msg.sh

case $1 in
    window)
        $wmmsg -m -t subscribe '["window"]' |
        jq --unbuffered -r 'if (.change=="close" and .container.focused==true) then 
            "" 
        else 
            (select(.change=="focus" or .change=="title") | .container.name)
        end'
        ;;
    mode)
        $wmmsg -m -t subscribe '["mode"]' |
        jq --unbuffered -r 'if (.change=="default") then 
            "" 
        else 
            (.change)
        end'
        ;;
    workspace)
        map_workroom() {
            case "$1" in
                a) echo "一" ;;
                b) echo "二" ;;
                c) echo "三" ;;
                d) echo "四" ;;
                e) echo "五" ;;
                f) echo "六" ;;
                *) echo "$1" ;;
            esac
        }

        declare -A mspaces

        while read -r m rws; do
            ws=${rws:0:1}
            wr=${rws:1:1}

            mspaces[$m]="$ws$wr$(map_workroom $wr)"
        done < <($wmmsg -t get_outputs | jq -r '.[] | "\(.name) \(.current_workspace)"')

        update() {
            local json="{"
            local first=1

            for m in "${!mspaces[@]}"; do
                (( first )) && first=0 || json+=", "
                json+="\"$m\": \"${mspaces[$m]}\""
            done

            json+="}"
            echo "$json"
        }

        update
        while read -r rws m; do
            ws=${rws:0:1}
            wr=${rws:1:1}

            mspaces[$m]="$ws$wr$(map_workroom $wr)"

            update
        done < <($wmmsg -m -t subscribe '["workspace"]' | jq --unbuffered -r 'select(.change=="focus") | .current | "\(.name) \(.output)"')
        ;;
    workspaces)
        declare -A mspaces

        raw=$($wmmsg -r -t get_workspaces)
        while read -r m rws; do
            workspaces=$(jq -r --arg room ${rws:1:1} '.[] | select(.name[1:2] == $room) | .name[0:1]' <<< $raw)
            mspaces[$m]=$(jq -Rrcs 'split("\n")[:-1]' <<< "${workspaces[@]}")
        done < <($wmmsg -t get_outputs | jq -r '.[] | "\(.name) \(.current_workspace)"')

        update() {
            local json="{"
            local first=1

            for m in "${!mspaces[@]}"; do
                (( first )) && first=0 || json+=", "
                json+="\"$m\": ${mspaces[$m]}"
            done

            json+="}"
            echo "$json"
        }

        update
        
        while read -r _; do 
            raw=$($wmmsg -r -t get_workspaces)
            raw_ws=$(jq -r '.[] | select(.focused==true)' <<< $raw)

            m=$(jq -r '.output' <<< $raw_ws)
            rws=$(jq -r '.name' <<< $raw_ws)

            workspaces=$(jq -r --arg room ${rws:1:1} '.[] | select(.name[1:2] == $room) | .name[0:1]' <<< $raw)

            mspaces[$m]=$(jq -Rrcs 'split("\n")[:-1]' <<< "${workspaces[@]}")

            update
        done < <($wmmsg -m -t subscribe '["workspace"]')
        ;;
esac
