import QtQuick
import "../core" as Core

Text {
    id: root

    text: "Vol " + Core.ShellState.volumeLevel + "%"
    color: Core.Theme.fg
    font.pixelSize: Core.Theme.fontSize
    font.family: Core.Theme.fontFamily
    font.bold: true
}
