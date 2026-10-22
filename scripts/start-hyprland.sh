#!/usr/bin/env bash
# Resolve DRM nodes on every login: card numbers can change across boots.
set -euo pipefail

amd=()
other=()
amd_pci=''
for card in /sys/class/drm/card[0-9]*; do
    name=${card##*/}
    [[ "$name" =~ ^card[0-9]+$ && -r "$card/device/vendor" ]] || continue
    vendor=$(<"$card/device/vendor")
    if [[ "$vendor" == '0x1002' ]]; then
        amd+=("/dev/dri/$name")
        [[ -n "$amd_pci" ]] || amd_pci=$(basename "$(readlink -f "$card/device")")
    else
        other+=("/dev/dri/$name")
    fi
done

if ((${#amd[@]})); then
    # Render the desktop on AMD. Keep NVIDIA available for its HDMI port and
    # applications explicitly launched with prime-run; it can idle otherwise.
    devices=("${amd[@]}" "${other[@]}")
    export AQ_DRM_DEVICES
    AQ_DRM_DEVICES=$(IFS=:; printf '%s' "${devices[*]}")
    export DRI_PRIME="pci-${amd_pci//[:.]/_}"
fi

if [[ "${1:-}" == '--print' ]]; then
    printf 'AQ_DRM_DEVICES=%s\nDRI_PRIME=%s\n' "${AQ_DRM_DEVICES:-automatic}" "${DRI_PRIME:-default}"
    exit 0
fi
exec Hyprland "$@"
