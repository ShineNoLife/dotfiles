#!/usr/bin/env bash
# Hyprland display switcher. Changes last until the next config reload.
# --auto: extend right without a menu. --dry-run: print commands only.
set -euo pipefail

fail() {
    printf 'Display Error: %s\n' "$*" >&2
    if command -v notify-send >/dev/null; then
        notify-send 'Display Error' "$*" || true
    fi
    exit 1
}

auto=false
dry_run=false
for arg in "$@"; do
    case "$arg" in
        --auto) auto=true ;;
        --dry-run) dry_run=true ;;
        --help|-h)
            printf 'Usage: %s [--auto] [--dry-run]\n' "$0"
            exit 0 ;;
        *) fail "Unknown option: $arg" ;;
    esac
done
for tool in hyprctl jq; do
    command -v "$tool" >/dev/null || fail "Missing dependency: $tool"
done
if ! $auto; then
    command -v rofi >/dev/null || fail 'Missing dependency: rofi (or use --auto)'
fi

monitors=$(hyprctl -j monitors all) || fail 'Cannot reach Hyprland.'
jq -e 'type == "array" and length > 0' <<< "$monitors" >/dev/null || fail 'No connected displays reported.'

# Include disabled outputs so Laptop Only / External Only can be reversed.
# Rank advertised modes by pixel count, then refresh rate, then dimensions.
rows=$(jq -r '
    .[] | select(.name | test("^(HEADLESS|WL-)") | not) |
    . as $monitor |
    [(.availableModes // [])[] |
        capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<hz>[0-9.]+)(Hz)?$")? |
        {w: (.w|tonumber), h: (.h|tonumber), hz: (.hz|tonumber)}] |
    sort_by([(.w * .h), .hz, .w, .h]) | last |
    if . == null then error("No usable advertised modes for " + $monitor.name)
    else [$monitor.name, "\(.w)x\(.h)@\(.hz)", .w, .h] | @tsv end
' <<< "$monitors") || fail 'Could not select supported display modes.'

declare -A modes widths heights
internal=''
externals=()
while IFS=$'\t' read -r name mode width height; do
    [[ -n "$name" ]] || continue
    modes["$name"]=$mode
    widths["$name"]=$width
    heights["$name"]=$height
    if [[ "$name" =~ ^(eDP|LVDS|DSI)- && -z "$internal" ]]; then
        internal=$name
    else
        externals+=("$name")
    fi
done <<< "$rows"

# Share the laptop's power-aware mode selection with the control panel.
# External displays continue using their highest resolution and refresh rate.
if [[ -n "$internal" ]]; then
    script_dir=$(dirname "$(readlink -f "$0")")
    modes["$internal"]=$(/usr/bin/python3 "$script_dir/scripts/display_power.py" --mode "$internal") ||
        fail 'Could not select the laptop display power mode.'
fi

selected='Both (Extend)'
position='Right of Laptop'
if ! $auto; then
    selected=$(printf '%s\n' 'Laptop Only' 'External Only' 'Both (Extend)' 'Duplicate (Mirror)' |
        rofi -dmenu -i -p 'Display Mode') || exit 0
    [[ -n "$selected" ]] || exit 0
fi
case "$selected" in
    'Laptop Only') [[ -n "$internal" ]] || fail 'No internal panel found.' ;;
    'External Only') ((${#externals[@]})) || fail 'No external display found.' ;;
    'Both (Extend)'|'Duplicate (Mirror)')
        # With only the laptop connected, --auto simply enables its best mode.
        if ((${#externals[@]} == 0)); then
            [[ -n "$internal" ]] || fail 'No usable display found.'
            selected='Laptop Only'
        fi ;;
    *) fail "Unknown display mode: $selected" ;;
esac
if [[ "$selected" == 'Both (Extend)' && -n "$internal" ]] && ! $auto; then
    position=$(printf '%s\n' 'Right of Laptop' 'Left of Laptop' 'Above Laptop' 'Below Laptop' |
        rofi -dmenu -i -p 'Position of External?') || exit 0
    [[ -n "$position" ]] || exit 0
    case "$position" in
        'Right of Laptop'|'Left of Laptop'|'Above Laptop'|'Below Laptop') ;;
        *) fail "Unknown position: $position" ;;
    esac
fi

run() {
    if $dry_run; then
        printf '%q ' hyprctl "$@"
        printf '\n'
        return
    fi
    local reply
    reply=$(hyprctl "$@") || fail 'Hyprland command failed; remaining changes stopped.'
    [[ "$reply" == 'ok' ]] || fail "Hyprland rejected the change: $reply"
}
enable() {
    local name=$1 pos=$2 mirror=${3:-}
    local rule="$name,${modes[$name]},$pos,1,transform,0"
    [[ -z "$mirror" ]] || rule+=",mirror,$mirror"
    run keyword monitor "$rule"
}

# Enable destination displays before disabling any existing screen.
case "$selected" in
    'Laptop Only')
        enable "$internal" 0x0
        for name in "${externals[@]}"; do run keyword monitor "$name,disable"; done ;;
    'Duplicate (Mirror)')
        source=$internal
        [[ -n "$source" ]] || source=${externals[0]}
        enable "$source" 0x0
        for name in "${externals[@]}"; do
            [[ "$name" == "$source" ]] || enable "$name" 0x0 "$source"
        done ;;
    'External Only'|'Both (Extend)')
        anchor=$internal
        if [[ "$selected" == 'External Only' || -z "$anchor" ]]; then
            anchor=${externals[0]}
        fi
        enable "$anchor" 0x0
        x=0; y=0
        prev=$anchor
        for name in "${externals[@]}"; do
            [[ "$name" != "$anchor" ]] || continue
            case "$position" in
                'Right of Laptop')
                    x=$((x + widths[$prev]))
                    y=$(((heights[$anchor] - heights[$name]) / 2)) ;;
                'Left of Laptop')
                    x=$((x - widths[$name]))
                    y=$(((heights[$anchor] - heights[$name]) / 2)) ;;
                'Above Laptop')
                    y=$((y - heights[$name]))
                    x=$(((widths[$anchor] - widths[$name]) / 2)) ;;
                'Below Laptop')
                    y=$((y + heights[$prev]))
                    x=$(((widths[$anchor] - widths[$name]) / 2)) ;;
            esac
            enable "$name" "${x}x${y}"
            prev=$name
        done
        if [[ "$selected" == 'External Only' && -n "$internal" ]]; then
            run keyword monitor "$internal,disable"
        fi ;;
esac
