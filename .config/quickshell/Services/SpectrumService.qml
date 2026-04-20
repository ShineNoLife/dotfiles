pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    // Spectrum values array (0.0–1.0) — bind from visualizer widgets
    property var values: []
    property bool isIdle: true
    readonly property int bandCount: 32

    // Component registration (only run cava when something needs it)
    property var _registeredComponents: ({})
    readonly property int _registeredCount: Object.keys(_registeredComponents).length
    readonly property bool _shouldRun: _registeredCount > 0

    function registerComponent(componentId) {
        root._registeredComponents[componentId] = true
        root._registeredComponents = Object.assign({}, root._registeredComponents)
    }

    function unregisterComponent(componentId) {
        delete root._registeredComponents[componentId]
        root._registeredComponents = Object.assign({}, root._registeredComponents)
    }

    on_ShouldRunChanged: {
        if (_shouldRun) {
            cavaProc.running = true
        } else {
            cavaProc.running = false
            root.values = []
            root.isIdle = true
        }
    }

    // cava outputs ascii values (0–1000) separated by semicolons
    Process {
        id: cavaProc
        running: false
        command: ["sh", "-c", [
            "cava -p /dev/stdin <<'EOF'",
            "[general]",
            "bars = " + root.bandCount,
            "framerate = 30",
            "[output]",
            "method = raw",
            "raw_target = /dev/stdout",
            "data_format = ascii",
            "ascii_max_range = 1000",
            "EOF"
        ].join("\n")]

        stdout: SplitParser {
            onRead: data => {
                if (!data) return
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
