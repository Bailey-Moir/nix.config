#!/usr/bin/env bash
for m in $(~/.config/scripts/wm-msg.sh -t get_outputs | jq -r '.[].name'); do
  eww open $@ --id ${!#}-$m --arg out=$m
done
