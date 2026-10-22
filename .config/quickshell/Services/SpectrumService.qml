pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

Singleton {
    id: root
    
    // Spectrum values array (0.0–1.0) — bind from visualizer widgets
    property var values: []
    property bool isIdle: true
    readonly property int bandCount: 32

    // Panel windows stay instantiated when hidden. Follow open/close state
    // instead of widget construction, with one shared process for all screens.
    readonly property bool active: !!Core.ShellState.openPanels["controlcenter"]
    readonly property bool running: cavaProc.running

    onActiveChanged: {
        if (!active) {
            root.values = []
            root.isIdle = true
        }
    }

    // cava outputs ascii values (0–1000) separated by semicolons, one frame per line
    // stdbuf -oL forces line-buffered stdout so frames arrive immediately
    Process {
        id: cavaProc
        running: root.active
        command: ["stdbuf", "-oL", "cava", "-p", Quickshell.shellDir + "/cava-spectrum.conf"]

        stdout: SplitParser {
            onRead: data => {
                if (!root.active || !data) return
                var parts = data.trim().replace(/;$/, "").split(";")
                var arr = []
                var idle = true
                for (var i = 0; i < parts.length; i++) {
                    var v = parseInt(parts[i]) / 1000.0
                    if (isNaN(v)) v = 0
                    if (v > 0.01) idle = false
                    arr.push(v)
                }
                root.values = arr
                root.isIdle = idle
            }
        }
    }
}
