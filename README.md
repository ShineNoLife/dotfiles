# Screenshots

![](images/image_1.png)

# Components

window manager: hyprland
terminal: kitty
gtk theme: everforest (the overall color scheme is also based on this)
file manager: nautilus
bar: waybar
menu: rofi 
lock screen: hyprlock
notifications center: swaync
wallpaper: ewww

# Laptop power saving

The control panel uses power-profiles-daemon. Power saver selects the laptop's
tested 1920x1200 60 Hz timing; leaving power saver restores its highest advertised
refresh rate (144 Hz). External displays retain their highest supported modes.
The policy also runs after monitor hotplug and Hyprland config reloads.

The audio visualizer runs only while the control panel is open.

TTY1 starts Hyprland through `scripts/start-hyprland.sh`, which discovers the AMD
GPU at login and makes it the primary renderer. NVIDIA remains available for HDMI
and explicit `prime-run` applications. GPU selection takes effect on the next
login; Hyprland cannot move a running compositor or existing apps between GPUs.
AMD rendering does not guarantee that NVIDIA sleeps if an app or HDMI needs it.
