import QtQuick
import Quickshell.Io
import "../core" as Core

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    
    // Battery state
    property int capacity: 100
    property string status: "Unknown"   // "Charging", "Discharging", "Full", "Unknown"
    property string governor: "powersave" // "powersave" or "performance"

    readonly property bool isCharging: status === "Charging" || status === "Full"

    readonly property string batteryIcon: {
        if (isCharging) return "󰂄"
        if (capacity >= 90) return "󰁹"
        if (capacity >= 70) return "󰂀"
        if (capacity >= 50) return "󰁾"
        if (capacity >= 30) return "󰁼"
        if (capacity >= 15) return "󰁺"
        return "󰂃"
    }

    readonly property color batteryColor: {
        if (isCharging) return Core.Theme.green
        if (capacity <= 15) return Core.Theme.red
        if (capacity <= 30) return Core.Theme.orange
        return Core.Theme.fg
    }

    readonly property string governorIcon: governor === "performance" ? "󱐋" : "󰌪"
    readonly property color governorColor: governor === "performance" ? Core.Theme.orange : Core.Theme.blue

    // ── Processes ──

    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return
                var v = parseInt(data.trim())
                if (!isNaN(v)) {
                    root.capacity = v
                } else {
                    root.status = data.trim()
                }
            }
        }
    }

    Process {
        id: governorProc
        command: ["cat", "/sys/devices/system/cpu/cpufreq/policy0/scaling_governor"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) root.governor = data.trim()
            }
        }
    }

    Process {
        id: setGovernorProc
        running: false
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryProc.running = true
            governorProc.running = true
        }
    }

    function toggleGovernor() {
        var next = governor === "powersave" ? "performance" : "powersave"
        setGovernorProc.command = ["sh", "-c",
            "for f in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor; do echo " + next + " | sudo tee $f > /dev/null; done"
        ]
        setGovernorProc.running = true
        governor = next
    }

    // ── UI ──

    Row {
        id: row
        spacing: Core.Theme.marginS

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "[" + root.governorIcon + "]"
            color: root.governorColor
            font.pixelSize: Core.Theme.fontSize
            font.family: Core.Theme.fontFamily
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon + " " + root.capacity + "%"
            color: root.batteryColor
            font.pixelSize: Core.Theme.fontSize
            font.family: Core.Theme.fontFamily
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleGovernor()
    }
}
