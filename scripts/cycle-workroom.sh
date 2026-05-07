#!/usr/bin/env bash

wr=$(~/.config/scripts/wm-msg.sh -r -t get_workspaces |
    jq -r '.[] | select(.focused==true) | .name' |
    cut -c2)

case $wr in
  a) wr="b" ;;
  b) wr="c" ;;
  c) wr="d" ;;
  d) wr="e" ;;
  e) wr="f" ;;
  f) wr="a" ;;
esac

~/.config/scripts/wm-msg.sh workspace "1$wr"
