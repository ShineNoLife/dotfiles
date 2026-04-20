pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Everforest Dark palette
    readonly property color bg: "#1E2326"
    readonly property color surface: "#272E33"
    readonly property color border: "#374145"
    readonly property color dim: "#0D000000"
    readonly property color fg: "#D3C6AA"
    readonly property color textMuted: "#859289"
    readonly property color green: "#A7C080"
    readonly property color blue: "#7FBBB3"
    readonly property color orange: "#E69875"
    readonly property color purple: "#D699B6"
    readonly property color red: "#E67E80"

    // Typography
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 16

    // Layout
    readonly property int barHeight: 30
    readonly property int overlayPanelWidth: 360
    readonly property int radius: 8
    readonly property int marginS: 4
    readonly property int marginM: 8
    readonly property int marginL: 16

    // control center panel layout
    readonly property int controlCenterPanelWidth: 360
    readonly property int controlCenterPanelHeight: 540
}
