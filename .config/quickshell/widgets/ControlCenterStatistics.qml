import QtQuick
import QtQuick.Layouts
import "../core" as Core 

Rectangle {
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 30
    color: Core.Theme.surface
    radius: Core.Theme.radius

    border.color: Core.Theme.border
    border.width: Core.Theme.borderWidth

    GridLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        columns: 3

        // ── CPU ──
        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Text {
                anchors.centerIn: parent
                text: Core.ShellState.cpuUsage + "% "
                color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                font.bold: true
            }
        }

        // ── Memory ──
        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Text {
                anchors.centerIn: parent
                text: Core.ShellState.memUsage.toFixed(2) + " GB "
                color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                font.bold: true
            }
        }

        // ── Volume ──
        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Text {
                anchors.centerIn: parent
                text: Core.ShellState.volumeLevel + "% 󱄠"
                color: Core.Theme.orange
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                font.bold: true
            }
        }

    }

}