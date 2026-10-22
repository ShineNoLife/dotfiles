import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "../core" as Core
import "../Services" as Services

Rectangle {
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + Core.Theme.marginM * 2
    color: Core.Theme.surface
    radius: Core.Theme.radius
    border.color: Core.Theme.border
    border.width: Core.Theme.borderWidth

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Core.Theme.marginM
        spacing: Core.Theme.marginM

        Text {
            text: "Buttons"
            color: Core.Theme.textMuted
            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize - 2
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Core.Theme.marginM
            rowSpacing: Core.Theme.marginM

            Button {
                id: powerButton
                Layout.fillWidth: true
                implicitHeight: 64
                enabled: Services.PowerService.available && !Services.PowerService.busy
                checked: Services.PowerService.powerSaving
                Accessible.name: "Power saving"
                Accessible.description: Services.PowerService.powerSaving ? "Enabled" : "Disabled"
                Accessible.checkable: true
                Accessible.checked: Services.PowerService.powerSaving
                onClicked: Services.PowerService.toggle()

                background: Rectangle {
                    radius: Core.Theme.radius
                    color: powerButton.checked ? Qt.alpha(Core.Theme.green, 0.15)
                        : powerButton.hovered ? Qt.alpha(Core.Theme.fg, 0.05) : "transparent"
                    border.color: powerButton.checked ? Core.Theme.green : Core.Theme.border
                    border.width: Core.Theme.borderWidth
                    opacity: powerButton.enabled ? 1 : 0.5
                }

                contentItem: Item {
                    implicitWidth: powerContent.implicitWidth
                    implicitHeight: powerContent.implicitHeight
                    opacity: powerButton.enabled ? 1 : 0.5

                    Column {
                        id: powerContent
                        anchors.centerIn: parent
                        spacing: Core.Theme.marginS

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Services.PowerService.busy ? "󰑓" : "󰌪"
                            color: powerButton.checked ? Core.Theme.green : Core.Theme.fg
                            font.family: Core.Theme.iconFontFamily
                            font.pixelSize: Core.Theme.fontSize
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Power saving"
                            color: powerButton.checked ? Core.Theme.green : Core.Theme.fg
                            font.family: Core.Theme.fontFamily
                            font.pixelSize: Core.Theme.fontSize - 3
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        Text {
            Layout.fillWidth: true
            text: Services.PowerService.error || Services.PowerService.displayError
            visible: text !== ""
            color: Core.Theme.red
            font.family: Core.Theme.fontFamily
            font.pixelSize: Core.Theme.fontSize - 3
            wrapMode: Text.WordWrap
        }
    }
}
