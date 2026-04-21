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
        if (!cavaProc.running) cavaProc.running = true
    }

    function unregisterComponent(componentId) {
        delete root._registeredComponents[componentId]
        root._registeredComponents = Object.assign({}, root._registeredComponents)
        if (root._registeredCount === 0) {
            cavaProc.running = false
            root.values = []
            root.isIdle = true
        }
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

    // cava outputs ascii values (0–1000) separated by semicolons, one frame per line
    // stdbuf -oL forces line-buffered stdout so frames arrive immediately
    Process {
        id: cavaProc
        running: false
        command: ["stdbuf", "-oL", "cava", "-p", Quickshell.shellDir + "/cava-spectrum.conf"]

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
