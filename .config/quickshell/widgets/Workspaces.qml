import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../core" as Core

RowLayout {
    id: root
    spacing: 0

    Repeater {
        model: 10

        Item {
            Layout.preferredWidth: 20
            Layout.preferredHeight: Core.Theme.barHeight
            
            required property int index

            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool hasWindows: workspace !== null

            Text {
                text: parent.index + 1
                color: parent.isActive ? Core.Theme.orange
                     : parent.hasWindows ? Core.Theme.green
                     : Core.Theme.fg
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                font.bold: true
                anchors.centerIn: parent
            }

            Rectangle {
                width: 20
                height: 3
                color: parent.isActive ? Core.Theme.orange : "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (parent.index + 1))
            }
        }
    }
}
