#!/usr/bin/env bash
if command -v swaymsg >/dev/null && [ -n "$SWAYSOCK" ]; then
    msg="swaymsg"
elif command -v i3-msg >/dev/null && [ -n "$I3SOCK" ]; then
    msg="i3-msg"
else
    echo "Not running Sway or i3" >&2
    exit 1
fi

exec "$msg" "$@"
