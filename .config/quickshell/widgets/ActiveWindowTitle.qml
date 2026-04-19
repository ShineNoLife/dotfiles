import QtQuick
import "../core" as Core

Text {
    id: root

    text: Core.ShellState.activeWindow || "Desktop"
    color: Core.Theme.blue
    font.pixelSize: Core.Theme.fontSize
    font.family: Core.Theme.fontFamily
    font.bold: true
    elide: Text.ElideRight
    maximumLineCount: 1
}
