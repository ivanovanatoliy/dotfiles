#!/usr/bin/env sh
set -eu

state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-tray-state"

get_state() {
  if [ -r "$state_file" ]; then
    read -r state <"$state_file"
    case "$state" in
      expanded|collapsed)
        printf '%s\n' "$state"
        return
        ;;
    esac
  fi
  printf 'collapsed\n'
}

registered_items() {
  busctl --user get-property \
    org.kde.StatusNotifierWatcher \
    /StatusNotifierWatcher \
    org.kde.StatusNotifierWatcher \
    RegisteredStatusNotifierItems 2>/dev/null | grep -oE '"[^"]+"' | tr -d '"'
}

valid_count() {
  count=0
  while IFS= read -r item; do
    [ -n "$item" ] || continue
    service=${item%%/*}
    path=/${item#*/}
    icon_name="$(busctl --user get-property "$service" "$path" org.kde.StatusNotifierItem IconName 2>/dev/null | sed -n 's/^s //p' | sed 's/^"//; s/"$//')"
    pixmap_count="$(busctl --user get-property "$service" "$path" org.kde.StatusNotifierItem IconPixmap 2>/dev/null | awk 'NR==1 {print $2}')"
    if [ -n "$icon_name" ] || [ "${pixmap_count:-0}" -gt 0 ]; then
      count=$((count + 1))
    fi
  done <<EOF_ITEMS
$(registered_items)
EOF_ITEMS
  printf '%s\n' "$count"
}

case "${1:-json}" in
  count)
    valid_count
    ;;
  has-icons)
    [ "$(valid_count)" -gt 0 ]
    ;;
  json)
    count="$(valid_count)"
    if [ "$count" -eq 0 ]; then
      printf '{"text":"","class":["tray-toggle","empty"]}\n'
      exit 0
    fi
    if [ "$(get_state)" = "expanded" ]; then
      printf '{"text":"›","class":["tray-toggle","expanded"]}\n'
    else
      printf '{"text":"‹","class":["tray-toggle","collapsed"]}\n'
    fi
    ;;
  *)
    printf 'unknown subcommand: %s\n' "${1:-}" >&2
    exit 1
    ;;
esac
