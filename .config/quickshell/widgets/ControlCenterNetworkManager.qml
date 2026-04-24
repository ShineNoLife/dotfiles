import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Io
import "../core" as Core

Rectangle {
    anchors {
        left: parent.left
        right: parent.right
    }
    height: contentCol.implicitHeight + Core.Theme.marginL * 2
    color: Core.Theme.surface
    radius: Core.Theme.radius

    border.color: Core.Theme.border
    border.width: 1
    
    id: root

    // ── State ──
    property string activeSSID: ""
    property int activeSignal: 0
    property string activeDevice: ""
    property bool wifiEnabled: true
    property var networks: []
    property bool scanning: false
    property string connectingSSID: ""
    property bool showNetworks: false

    readonly property string wifiIcon: {
        if (!wifiEnabled) return "󰤭"
        if (activeSignal >= 75) return "󰤨"
        if (activeSignal >= 50) return "󰤥"
        if (activeSignal >= 25) return "󰤢"
        if (activeSignal > 0)   return "󰤟"
        return "󰤯"
    }

    // ── Processes ──

    // Single process: get wifi device name + enabled state
    Process {
        id: statusProc
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device | grep ':wifi:'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return
                // format: wlo1:wifi:connected
                var parts = data.trim().split(":")
                root.activeDevice = parts[0]
                var state = parts[2] || ""
                root.wifiEnabled = (state === "connected" || state === "disconnected")
            }
        }
    }

    // Single process: get currently connected SSID + signal
    Process {
        id: activeProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL device wifi | grep '^yes:'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return
                // format: yes:SSID:signal
                var line = data.trim()
                var firstColon = line.indexOf(":")
                var rest = line.slice(firstColon + 1)   // "SSID:signal"
                var lastColon = rest.lastIndexOf(":")
                root.activeSSID = rest.slice(0, lastColon)
                root.activeSignal = parseInt(rest.slice(lastColon + 1)) || 0
            }
        }
        onExited: code => {
            // grep exits 1 when no match = not connected
            if (code !== 0) {
                root.activeSSID = ""
                root.activeSignal = 0
            }
        }
    }

    // Scan all networks
    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "device", "wifi", "list"]
        property var _buf: []
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return
                var line = data.trim()
                // Last field is ACTIVE (yes/no), second last is SECURITY, second is SIGNAL
                // Split from the right to avoid SSID colon issues
                var lastColon = line.lastIndexOf(":")
                var active = line.slice(lastColon + 1) === "yes"
                var rest = line.slice(0, lastColon)          // SSID:SIGNAL:SECURITY
                var secColon = rest.lastIndexOf(":")
                var security = rest.slice(secColon + 1)
                var rest2 = rest.slice(0, secColon)          // SSID:SIGNAL
                var sigColon = rest2.lastIndexOf(":")
                var signal = parseInt(rest2.slice(sigColon + 1)) || 0
                var ssid = rest2.slice(0, sigColon)
                if (!ssid) return
                scanProc._buf.push({ ssid, signal, security, active })
            }
        }
        onExited: {
            var seen = {}
            var sorted = _buf.slice().sort((a, b) => b.signal - a.signal)
            root.networks = sorted.filter(n => {
                if (seen[n.ssid]) return false
                seen[n.ssid] = true
                return true
            })
            _buf = []
            root.scanning = false
        }
    }

    Process {
        id: connectProc
        running: false
        onExited: { root.connectingSSID = ""; root.scan(); root.refreshStatus() }
    }

    Process {
        id: disconnectProc
        running: false
        onExited: { root.activeSSID = ""; root.activeSignal = 0; root.scan() }
    }

    Process {
        id: toggleWifiProc
        running: false
        onExited: refreshStatus()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { root.refreshStatus(); root.scan() }
    }

    function refreshStatus() {
        statusProc.running = true
        activeProc.running = true
    }

    function scan() {
        if (scanning) return
        scanning = true
        scanProc._buf = []
        scanProc.running = true
    }

    function connectTo(ssid) {
        connectingSSID = ssid
        connectProc.command = ["nmcli", "device", "wifi", "connect", ssid]
        connectProc.running = true
    }

    function disconnect() {
        disconnectProc.command = ["nmcli", "device", "disconnect", root.activeDevice]
        disconnectProc.running = true
    }

    function toggleWifi() {
        var action = wifiEnabled ? "off" : "on"
        toggleWifiProc.command = ["nmcli", "radio", "wifi", action]
        toggleWifiProc.running = true
        wifiEnabled = !wifiEnabled
    }

    // ── UI ──

    ColumnLayout {
        id: contentCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Core.Theme.marginL
        }
        spacing: Core.Theme.marginM

        // Header row
        RowLayout {
            Layout.fillWidth: true
            spacing: Core.Theme.marginM

            // Wifi icon + SSID
            Text {
                text: root.wifiIcon
                color: root.wifiEnabled ? Core.Theme.blue : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize + 4
                font.family: Core.Theme.fontFamily
            }

            Text {
                Layout.fillWidth: true
                text: root.wifiEnabled ? (root.activeSSID || "Not connected") : "Wi-Fi off"
                color: root.activeSSID ? Core.Theme.fg : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                font.bold: !!root.activeSSID
                elide: Text.ElideRight
            }

            // // Signal strength
            // Text {
            //     text: root.activeSignal > 0 ? root.activeSignal + "%" : ""
            //     color: Core.Theme.textMuted
            //     font.pixelSize: Core.Theme.fontSize - 2
            //     font.family: Core.Theme.fontFamily
            //     visible: root.wifiEnabled && root.activeSignal > 0
            // }

            // Toggle wifi on/off
            Rectangle {
                width: 32
                height: 16
                radius: Core.Theme.radius
                color: root.wifiEnabled
                    ? Qt.rgba(Qt.color(Core.Theme.green).r, Qt.color(Core.Theme.green).g, Qt.color(Core.Theme.green).b, 0.15)
                    : "transparent"
                border.color: root.wifiEnabled ? Core.Theme.green : Core.Theme.border
                border.width: 2

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleWifi()
                }
            }

            // Scan / refresh
            Text {
                text: root.scanning ? "󰑓" : "󰍉"
                color: root.showNetworks ? Core.Theme.blue : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize + 2
                font.family: Core.Theme.fontFamily
                opacity: root.scanning ? 0.5 : 1.0
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.showNetworks = !root.showNetworks
                        if (root.showNetworks) root.scan()
                    }
                }
            }
        }

        // Network list
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 100)
            visible: root.showNetworks && root.networks.length > 0
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: parent.width
                spacing: 2

                Repeater {
                    model: root.networks

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 28
                        radius: Core.Theme.radius / 2

                        readonly property bool isConnecting: root.connectingSSID === modelData.ssid
                        readonly property bool isActive: modelData.active

                        color: {
                            if (isActive)
                                return Qt.rgba(Qt.color(Core.Theme.green).r, Qt.color(Core.Theme.green).g, Qt.color(Core.Theme.green).b, 0.15)
                            if (isConnecting)
                                return Qt.rgba(Qt.color(Core.Theme.orange).r, Qt.color(Core.Theme.orange).g, Qt.color(Core.Theme.orange).b, 0.15)
                            if (rowArea.containsMouse)
                                return Qt.rgba(1, 1, 1, 0.05)
                            return "transparent"
                        }

                        Behavior on color { ColorAnimation { duration: 120 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Core.Theme.marginM
                            anchors.rightMargin: Core.Theme.marginM
                            spacing: Core.Theme.marginS

                            Text {
                                Layout.fillWidth: true
                                text: modelData.ssid
                                color: isActive ? Core.Theme.green : isConnecting ? Core.Theme.orange : Core.Theme.fg
                                font.pixelSize: Core.Theme.fontSize - 1
                                font.family: Core.Theme.fontFamily
                                font.bold: isActive || isConnecting
                                elide: Text.ElideRight
                            }

                            // Connecting spinner or signal icon
                            Text {
                                text: {
                                    if (isConnecting) return "󰑓"
                                    var s = modelData.signal
                                    if (s >= 75) return "󰤨"
                                    if (s >= 50) return "󰤥"
                                    if (s >= 25) return "󰤢"
                                    return "󰤟"
                                }
                                color: isConnecting ? Core.Theme.orange : Core.Theme.textMuted
                                font.pixelSize: Core.Theme.fontSize - 2
                                font.family: Core.Theme.fontFamily
                            }
                        }

                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                if (isActive) root.disconnect()
                                else if (!root.connectingSSID) root.connectTo(modelData.ssid)
                            }
                        }
                    }
                }
            }
        }
    }
}
