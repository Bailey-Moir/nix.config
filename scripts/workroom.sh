#!/usr/bin/env bash
~/.config/scripts/wm-msg.sh -r -t get_workspaces |
    jq -r '.[] | select(.focused==true) | .name' |
    cut -c2
