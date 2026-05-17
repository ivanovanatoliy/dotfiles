#!/usr/bin/env sh
set -eu
state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-tray-state"

state="collapsed"
if [ -r "$state_file" ]; then
  read -r state < "$state_file"
fi
if [ "$state" = "expanded" ]; then
  printf 'collapsed\n' > "$state_file"
else
  printf 'expanded\n' > "$state_file"
fi
pkill -RTMIN+9 waybar >/dev/null 2>&1 || true
