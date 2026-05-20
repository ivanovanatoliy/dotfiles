#!/usr/bin/env sh
exec waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" >>"${XDG_RUNTIME_DIR:-/tmp}/waybar.log" 2>&1
