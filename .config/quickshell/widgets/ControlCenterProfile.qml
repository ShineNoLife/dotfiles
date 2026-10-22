import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import "../core" as Core 

Rectangle {
    Layout.fillWidth: true
    implicitHeight: 44
    color: Core.Theme.surface
    radius: Core.Theme.radius

    border.color: Core.Theme.border
    border.width: Core.Theme.borderWidth

    component ActionButton: Button {
        id: action

        property color iconColor: Core.Theme.fg
        implicitWidth: 28
        implicitHeight: 28
        Layout.minimumWidth: 28
        Layout.maximumWidth: 28
        Layout.minimumHeight: 28
        Layout.maximumHeight: 28
        padding: 0

        background: Rectangle {
            radius: Core.Theme.radius
            color: action.down ? Qt.alpha(action.iconColor, 0.15)
                : action.hovered ? Qt.alpha(action.iconColor, 0.07) : "transparent"
            border.color: action.hovered ? Qt.alpha(action.iconColor, 0.8) : Qt.alpha(Core.Theme.border, 0.55)
            border.width: Core.Theme.borderWidth
        }

        contentItem: Item {
            TextMetrics {
                id: glyphMetrics
                text: glyph.text
                font: glyph.font
                renderType: glyph.renderType
            }

            Text {
                id: glyph
                text: action.text
                color: action.iconColor
                font.family: Core.Theme.iconFontFamily
                font.pixelSize: Core.Theme.fontSize - 3
                // Center the visible ink, including each glyph's font bearings.
                x: Math.round((parent.width - glyphMetrics.tightBoundingRect.width) / 2
                    - glyphMetrics.tightBoundingRect.x)
                y: Math.round((parent.height - glyphMetrics.tightBoundingRect.height) / 2
                    - baselineOffset - glyphMetrics.tightBoundingRect.y)
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        spacing: Core.Theme.marginM
        
        // profile
        ClippingRectangle {
            implicitWidth: 28
            implicitHeight: 28
            color: Core.Theme.surface
            radius: width/2

            border.color: Core.Theme.border
            border.width: Core.Theme.borderWidth

            Image {
                anchors.fill: parent
                source: "../icons/profile.png"
                fillMode: Image.PreserveAspectCrop
            }
        }

        Item { Layout.fillWidth: true }

        // reload
        ActionButton {
            text: "󰑓"
            iconColor: Core.Theme.blue
            Accessible.name: "Reload shell"
            onClicked: Quickshell.reload(false)
        }

        // lock
        ActionButton {
            text: "\uDB80\uDF3E" // Nerd Font: lock
            Accessible.name: "Lock screen"
            onClicked: Core.ShellState.lock()
        }

        // reboot
        ActionButton {
            text: "\uDB81\uDF09" // Nerd Font: restart
            Accessible.name: "Restart"
            onClicked: Core.ShellState.reboot()
        }

        // shutdown
        ActionButton {
            text: "\uDB81\uDC25" // Nerd Font: power
            Accessible.name: "Shut down"
            onClicked: Core.ShellState.shutdown()
        }
        
    }
}
