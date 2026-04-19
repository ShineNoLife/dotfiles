import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../core" as Core

PanelWindow {
    id: overlaySurface

    color: "transparent"
    surfaceFormat.opaque: false

    visible: Core.ShellState.overlayOpen
    focusable: Core.ShellState.overlayOpen
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    margins.top: Core.Theme.barHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-overlay"

    // ── Scrim ──
    Rectangle {
        anchors.fill: parent
        color: Core.Theme.scrim

        MouseArea {
            anchors.fill: parent
            onClicked: Core.ShellState.overlayOpen = false
        }
    }

    // ── Settings panel ──
    Rectangle {
        id: panel

        width: Core.Theme.overlayPanelWidth

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            topMargin: Core.Theme.marginM
            rightMargin: Core.Theme.marginM
            bottomMargin: Core.Theme.marginM
        }

        radius: Core.Theme.radius
        color: Core.Theme.surface
        border.color: Core.Theme.border
        border.width: 1

        // Block scrim click-through
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Core.Theme.marginL
            spacing: 12

            // Header
            Text {
                text: "System Monitor"
                color: Core.Theme.blue
                font.pixelSize: 16
                font.family: Core.Theme.fontFamily
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Core.Theme.border
            }

            // ── CPU ──
            RowLayout {
                spacing: 8
                Text {
                    text: "CPU"
                    color: Core.Theme.fg
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Core.ShellState.cpuUsage + "%"
                    color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: Core.Theme.border
                Rectangle {
                    width: parent.width * Core.ShellState.cpuUsage / 100
                    height: parent.height
                    radius: 3
                    color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            // ── Memory ──
            RowLayout {
                spacing: 8
                Text {
                    text: "Memory"
                    color: Core.Theme.fg
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Core.ShellState.memUsage.toFixed(2) + " GB"
                    color: Core.Theme.purple
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: Core.Theme.border
                Rectangle {
                    width: parent.width * Math.min(Core.ShellState.memUsage / 16, 1)
                    height: parent.height
                    radius: 3
                    color: Core.Theme.purple
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            // ── Volume ──
            RowLayout {
                spacing: 8
                Text {
                    text: "Volume"
                    color: Core.Theme.fg
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Core.ShellState.volumeLevel + "%"
                    color: Core.Theme.orange
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: Core.Theme.border
                Rectangle {
                    width: parent.width * Core.ShellState.volumeLevel / 100
                    height: parent.height
                    radius: 3
                    color: Core.Theme.orange
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
