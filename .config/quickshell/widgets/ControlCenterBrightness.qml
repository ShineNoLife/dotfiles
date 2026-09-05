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

    component ControlSlider: ColumnLayout {
        id: control
        required property string label
        required property string accessibleLabel
        property string status: Math.round(value) + "%"
        property alias value: slider.value
        property alias minimum: slider.from
        signal moved(real value)

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.minimumWidth: 0
        spacing: Core.Theme.marginS

        RowLayout {
            Layout.fillWidth: true
            spacing: Core.Theme.marginS

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: control.label
                elide: Text.ElideRight
                color: Core.Theme.fg
                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSize - 2
            }

            Text {
                text: control.enabled ? control.status : "N/A"
                color: Core.Theme.textMuted
                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSize - 2
            }
        }

        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            implicitHeight: 24
            from: 0
            to: 100
            stepSize: 1
            onMoved: control.moved(value)
            Accessible.name: control.accessibleLabel

            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: slider.availableWidth
                height: 6
                radius: Core.Theme.radius
                color: Core.Theme.border

                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: slider.enabled ? Core.Theme.green : Core.Theme.textMuted
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                width: 14
                height: 14
                radius: 7
                color: slider.enabled ? Core.Theme.green : Core.Theme.textMuted
                border.color: slider.activeFocus ? Core.Theme.fg : color
                border.width: 2
            }
        }
    }

    GridLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        rows: 1
        columns: 2
        columnSpacing: Core.Theme.marginL

        ControlSlider {
            label: "󰃠 Brightness"
            accessibleLabel: "Screen brightness"
            minimum: 1
            enabled: Services.BrightnessService.available
            value: Services.BrightnessService.brightnessPercent
            onMoved: value => Services.BrightnessService.setBrightness(value)
        }

        ControlSlider {
            label: Services.AudioService.volumeIcon + " Volume"
            accessibleLabel: "System volume"
            enabled: !!Services.AudioService.sink && !!Services.AudioService.sink.audio
            value: Services.AudioService.volumePercent
            status: Services.AudioService.muted ? "Muted" : Math.round(value) + "%"
            onMoved: value => Services.AudioService.setVolume(value / 100)
        }
    }
}
