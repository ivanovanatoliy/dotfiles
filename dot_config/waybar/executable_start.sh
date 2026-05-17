#!/usr/bin/env sh
set -eu

config_dir="$HOME/.config/waybar"
base_config="$config_dir/config.jsonc"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
runtime_config="$runtime_dir/waybar-config.jsonc"
tray_state_file="$runtime_dir/waybar-tray-state"
log_file="$runtime_dir/waybar.log"

enabled_outputs() {
	if ! command -v wlr-randr >/dev/null 2>&1; then
		printf 'eDP-1\n'
		return
	fi

	wlr-randr 2>/dev/null | awk '
		/^[^[:space:]]/ { output = $1 }
		/^  Enabled: yes$/ { print output }
	'
}

pick_tray_output() {
	outputs="$(enabled_outputs)"

	if printf '%s\n' "$outputs" | grep -qx 'eDP-1'; then
		printf 'eDP-1\n'
		return
	fi

	if [ -n "$outputs" ]; then
		printf '%s\n' "$outputs" | head -n1
		return
	fi

	printf 'eDP-1\n'
}

tray_output="$(pick_tray_output)"

if command -v jq >/dev/null 2>&1; then
	other_outputs_json="$(
		enabled_outputs | awk -v tray="$tray_output" '$0 != tray' | jq -R . | jq -s .
	)"

	if [ "$other_outputs_json" = "[]" ]; then
			jq \
				--arg tray_output "$tray_output" \
				'[. + {name: "river-bar", output: $tray_output}]' \
				"$base_config" >"$runtime_config"
		else
			jq \
				--arg tray_output "$tray_output" \
				--argjson other_outputs "$other_outputs_json" \
				'[
					(. + {name: "river-bar", output: $tray_output}),
					(. + {name: "river-bar", output: $other_outputs}
					 | .["modules-right"] |= map(select(. != "group/tray-drawer")))
				]' \
				"$base_config" >"$runtime_config"
	fi

	config_path="$runtime_config"
else
	config_path="$base_config"
fi

printf '%s\n' collapsed >"$tray_state_file"
pkill -x waybar >/dev/null 2>&1 || true
exec waybar -c "$config_path" -s "$config_dir/style.css" >>"$log_file" 2>&1
