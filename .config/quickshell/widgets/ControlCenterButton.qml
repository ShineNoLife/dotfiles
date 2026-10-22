import QtQuick
import "../core" as Core

Item {
    id: root

    width: Core.Theme.barHeight
    height: Core.Theme.barHeight
    
    Text {
        text: "\uf013" // Nerd Font: settings
        color: Core.ShellState.openPanels["controlcenter"] ? Core.Theme.orange : Core.Theme.fg
        font.pixelSize: Core.Theme.fontSize
        font.family: Core.Theme.iconFontFamily
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Core.ShellState.togglePanel("controlcenter")
    }
}
