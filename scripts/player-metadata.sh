#!/usr/bin/env bash
playerctl metadata --format "{{ $1 }}" -F| stdbuf -oL awk '{ print; fflush(); }'
