#!/bin/bash
INTERNAL="eDP-1"

# 1. Safer detection using jq (handles names better than grep)
EXTERNAL=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "'$INTERNAL'").name' | head -n 1)

if [ -z "$EXTERNAL" ]; then
    notify-send "Display Error" "No external monitor found."
    exit 1
fi

# 2. Main Menu - Added "Duplicate (Mirror)"
options="Laptop Only\nExternal Only\nBoth (Extend)\nDuplicate (Mirror)"
selected=$(echo -e "$options" | rofi -dmenu -i -p "Display Mode")

case $selected in
    "Laptop Only")
        swaymsg output "$EXTERNAL" disable
        swaymsg output "$INTERNAL" enable
        ;;
    "External Only")
        swaymsg output "$INTERNAL" disable
        swaymsg output "$EXTERNAL" enable
        ;;
    "Duplicate (Mirror)")
        # Enable both displays
        swaymsg output "$INTERNAL" enable
        swaymsg output "$EXTERNAL" enable
        sleep 0.5
        
        # Mirroring in Sway is achieved by stacking them at the exact same coordinates
        swaymsg output "$INTERNAL" pos 0 0
        swaymsg output "$EXTERNAL" pos 0 0
        ;;
    "Both (Extend)")
        # Enable both to read resolutions
        swaymsg output "$INTERNAL" enable
        swaymsg output "$EXTERNAL" enable
        sleep 0.5

        # Force Workspaces 1-5 to External
        for i in {1..5}; do
            swaymsg workspace $i output "$EXTERNAL"
        done

        # Force Workspaces 6-10 to Laptop (Internal)
        for i in {6..10}; do
            swaymsg workspace $i output "$INTERNAL"
        done

        # Get Dimensions
        INT_W=$(swaymsg -t get_outputs | jq -r '.[] | select(.name=="'$INTERNAL'") | .rect.width')
        INT_H=$(swaymsg -t get_outputs | jq -r '.[] | select(.name=="'$INTERNAL'") | .rect.height')
        EXT_W=$(swaymsg -t get_outputs | jq -r '.[] | select(.name=="'$EXTERNAL'") | .rect.width')
        EXT_H=$(swaymsg -t get_outputs | jq -r '.[] | select(.name=="'$EXTERNAL'") | .rect.height')

        # Sub-menu
        pos_options="Right of Laptop\nLeft of Laptop\nAbove Laptop\nBelow Laptop"
        pos_selected=$(echo -e "$pos_options" | rofi -dmenu -i -p "Position of External?")

        case $pos_selected in
            "Right of Laptop")
                # Center Vertically
                DIFF_H=$(( ($EXT_H - $INT_H) / 2 ))
                if [ $EXT_H -gt $INT_H ]; then
                    swaymsg output "$INTERNAL" pos 0 "$DIFF_H"
                    swaymsg output "$EXTERNAL" pos "$INT_W" 0
                else
                    DIFF_H=${DIFF_H#-} # Absolute value
                    swaymsg output "$INTERNAL" pos 0 0
                    swaymsg output "$EXTERNAL" pos "$INT_W" "$DIFF_H"
                fi
                ;;
            "Left of Laptop")
                # Center Vertically
                DIFF_H=$(( ($EXT_H - $INT_H) / 2 ))
                if [ $EXT_H -gt $INT_H ]; then
                    swaymsg output "$EXTERNAL" pos 0 0
                    swaymsg output "$INTERNAL" pos "$EXT_W" "$DIFF_H"
                else
                    DIFF_H=${DIFF_H#-}
                    swaymsg output "$EXTERNAL" pos 0 "$DIFF_H"
                    swaymsg output "$INTERNAL" pos "$EXT_W" 0
                fi
                ;;
            "Above Laptop")
                # Center Horizontally (Fixes the "weird" wall issue)
                DIFF_W=$(( ($EXT_W - $INT_W) / 2 ))
                if [ $EXT_W -gt $INT_W ]; then
                    swaymsg output "$EXTERNAL" pos 0 0
                    swaymsg output "$INTERNAL" pos "$DIFF_W" "$EXT_H"
                else
                    DIFF_W=${DIFF_W#-}
                    swaymsg output "$EXTERNAL" pos "$DIFF_W" 0
                    swaymsg output "$INTERNAL" pos 0 "$EXT_H"
                fi
                ;;
            "Below Laptop")
                # Center Horizontally
                DIFF_W=$(( ($EXT_W - $INT_W) / 2 ))
                if [ $EXT_W -gt $INT_W ]; then
                    swaymsg output "$INTERNAL" pos "$DIFF_W" 0
                    swaymsg output "$EXTERNAL" pos 0 "$INT_H"
                else
                    DIFF_W=${DIFF_W#-}
                    swaymsg output "$INTERNAL" pos 0 0
                    swaymsg output "$EXTERNAL" pos "$DIFF_W" "$INT_H"
                fi
                ;;
        esac
        ;;
esac
