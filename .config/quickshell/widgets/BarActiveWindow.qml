import QtQuick
import "../core" as Core

Text {
    id: root

    text: {
        var t = Core.ShellState.activeWindow || "Desktop"
        return t.length > 50 ? t.slice(0, 50) + "…" : t
    }
    color: Core.Theme.blue
    font.pixelSize: Core.Theme.fontSize
    font.family: Core.Theme.fontFamily
    font.bold: true
    elide: Text.ElideRight
    maximumLineCount: 1
}
