pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property int brightnessPercent: 0
    property string device: ""
    property int pendingPercent: -1

    function refresh() {
        if (brightnessProc.running || pendingPercent >= 0) return
        brightnessProc.command = ["brightnessctl", "-m", "-c", "backlight", "info"]
        brightnessProc.running = true
    }

    function setBrightness(percent) {
        if (!available || !isFinite(percent)) return
        // Keep the display lit and coalesce rapid slider movements.
        pendingPercent = Math.max(1, Math.min(100, Math.round(percent)))
        brightnessPercent = pendingPercent
    }

    Process {
        id: brightnessProc
        stdout: SplitParser {
            onRead: data => {
                var fields = data.trim().split(",")
                var percent = parseInt(fields[3])
                if (fields[1] !== "backlight" || !isFinite(percent)) return
                root.device = fields[0]
                root.available = true
                if (root.pendingPercent < 0)
                    root.brightnessPercent = Math.max(0, Math.min(100, percent))
            }
        }
        onExited: code => {
            if (code !== 0) {
                root.available = false
                root.pendingPercent = -1
            }
        }
    }

    Timer {
        interval: 80
        running: root.pendingPercent >= 0
        repeat: true
        onTriggered: {
            if (brightnessProc.running) return
            var percent = root.pendingPercent
            root.pendingPercent = -1
            brightnessProc.command = ["brightnessctl", "-m", "-c", "backlight",
                "-d", root.device, "set", percent + "%"]
            brightnessProc.running = true
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
