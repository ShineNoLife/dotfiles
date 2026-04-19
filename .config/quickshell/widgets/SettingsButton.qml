import QtQuick
import "../core" as Core

Rectangle {
    id: root

    width: Core.Theme.barHeight
    height: Core.Theme.barHeight
    color: "transparent"

    Text {
        text: "⚙"
        color: Core.ShellState.overlayOpen ? Core.Theme.orange : Core.Theme.fg
        font.pixelSize: Core.Theme.fontSize
        font.family: Core.Theme.fontFamily
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Core.ShellState.toggleOverlay()
    }
}
