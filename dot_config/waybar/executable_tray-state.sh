#!/usr/bin/env sh
set -eu

state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-tray-state"

get_state() {
  if [ -r "$state_file" ]; then
    read -r state <"$state_file"
    case "$state" in
      expanded|collapsed)
        printf '%s\n' "$state" || return 0
        return
        ;;
    esac
  fi
  printf 'collapsed\n' || return 0
}

case "${1:-json}" in
  count)
    printf '1\n' || exit 0
    ;;
  has-icons)
    exit 0
    ;;
  json)
    if [ "$(get_state)" = "expanded" ]; then
      printf '{"text":"›","class":["tray-toggle","expanded"]}\n' || exit 0
    else
      printf '{"text":"‹","class":["tray-toggle","collapsed"]}\n' || exit 0
    fi
    ;;
  *)
    printf 'unknown subcommand: %s\n' "${1:-}" >&2
    exit 1
    ;;
esac
