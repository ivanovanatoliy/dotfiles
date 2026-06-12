#!/usr/bin/env sh
set -u

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
label_color="#eeeeee"
value_color="#878787"
volume_state_file="${runtime_dir}/waybar_volume_state"

battery() {
	if [ -r /sys/class/power_supply/BAT0/capacity ]; then
		read -r battery </sys/class/power_supply/BAT0/capacity || battery="n/a"
		printf '%s%%' "$battery"
	else
		printf 'n/a'
	fi
}

live_volume() {
	if ! command -v pamixer >/dev/null 2>&1; then
		printf 'n/a'
		return
	fi
	if [ "$(pamixer --get-mute 2>/dev/null || printf true)" = "true" ]; then
		printf '0%%'
		return
	fi
	vol="$(pamixer --get-volume 2>/dev/null || true)"
	if [ -n "$vol" ]; then
		printf '%s%%' "$vol"
	else
		printf 'n/a'
	fi
}

volume() {
	if [ -r "$volume_state_file" ]; then
		read -r cached <"$volume_state_file" || cached=""
		if [ -n "$cached" ]; then
			printf '%s' "$cached"
			return
		fi
	fi
	live_volume
}

keymap() {
	layout="$(mmsg get keyboardlayout 2>/dev/null | jq -r '.layout // empty')"

	[ "$layout" = "Russian" ] && echo "RU" || echo "EN"
}

clock_text() {
	date '+%H:%M %a %d-%m'
}

bat="$(battery)"
vol="$(volume)"
km="$(keymap)"
clk="$(clock_text)"

printf '<span foreground="%s">BAT</span> <span foreground="%s">%s</span> <span foreground="%s">|</span> <span foreground="%s">VOL</span> <span foreground="%s">%s</span> <span foreground="%s">|</span> <span foreground="%s">%s</span> <span foreground="%s">|</span> <span foreground="%s">%s</span>\n' \
	"$label_color" "$value_color" "$bat" \
	"$value_color" "$label_color" "$value_color" "$vol" \
	"$value_color" "$value_color" "$km" \
	"$value_color" "$value_color" "$clk" || exit 0
