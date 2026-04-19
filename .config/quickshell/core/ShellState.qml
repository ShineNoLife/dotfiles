pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // Panel registry
    property var openPanels: ({})
    property var panelOrder: []
    readonly property bool overlayOpen: panelOrder.length > 0

    function openPanel(name) {
        if (openPanels[name]) return
        let p = Object.assign({}, openPanels)
        p[name] = true
        openPanels = p
        panelOrder = panelOrder.concat(name)
    }

    function closePanel(name) {
        if (!openPanels[name]) return
        let p = Object.assign({}, openPanels)
        delete p[name]
        openPanels = p
        panelOrder = panelOrder.filter(n => n !== name)
    }

    function togglePanel(name) {
        if (openPanels[name]) closePanel(name)
        else openPanel(name)
    }

    function closeAllPanels() {
        openPanels = {}
        panelOrder = []
    }

    // System info
    property string activeWindow: ""
    property int cpuUsage: 0
    property real memUsage: 0
    property int volumeLevel: 0

    // CPU tracking internals
    property int lastCpuIdle: 0
    property int lastCpuTotal: 0

    // ── Processes ──

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0
                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait
                if (root.lastCpuTotal > 0) {
                    var totalDiff = total - root.lastCpuTotal
                    var idleDiff = idleTime - root.lastCpuIdle
                    if (totalDiff > 0)
                        root.cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                }
                root.lastCpuTotal = total
                root.lastCpuIdle = idleTime
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var used = parseFloat(parts[2]) || 0
                root.memUsage = used / 1048576
            }
        }
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match) root.volumeLevel = Math.round(parseFloat(match[1]) * 100)
            }
        }
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) root.activeWindow = data.trim()
            }
        }
    }

    Process { 
        id: lockProc 
        command: ["hyprlock"]
    }
    Process { 
        id: rebootProc
        command: ["reboot"]
    }
    Process { 
        id: shutdownProc
        command: ["shutdown", "now"]
    }

    // functions
    function lock() {
        lockProc.running = true
    }

    function reboot() {
        rebootProc.running = true
    }

    function shutdown() {
        shutdownProc.running = true
    }


    // ── Timers ──

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            volProc.running = true
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
        }
    }

    // global shortcuts, change in hyprland's keybinds.conf

    GlobalShortcut {
        name: "overlay"
        onPressed: root.togglePanel("controlcenter")
    }
}
