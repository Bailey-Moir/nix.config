#!/usr/bin/env bash
udevadm monitor --subsystem-match=backlight -u | while read -r _; do
    cat /sys/class/backlight/amdgpu_bl1/brightness
done
