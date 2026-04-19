import QtQuick
import "../core" as Core

Text {
    id: root

    property string timeStr: ""

    text: timeStr
    color: Core.Theme.blue
    font.pixelSize: Core.Theme.fontSize
    font.family: Core.Theme.fontFamily
    font.bold: true

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.timeStr = Qt.formatDateTime(new Date(), "hh:mm dddd, MMMM d")
    }
}
