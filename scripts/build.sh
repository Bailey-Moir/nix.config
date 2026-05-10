#!/usr/bin/env zsh
set -e
pushd -q /etc/nixos/
git diff -U0 *.nix
echo "NixOS Rebuilding..."
export SUDO_ASKPASS=$(which lxqt-openssh-askpass)
sudo -A nixos-rebuild switch --impure --flake /etc/nixos#$(hostname) &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations --json | jq '.[] | select(.current==true).generation')
git commit -am "$(hostname): $gen"
popd -q
notify-send "Switched" "NixOS build completed successfully"
sleep 1 && eww reload &
