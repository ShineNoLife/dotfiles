import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../core" as Core
import "../Services" as Services

ClippingRectangle {
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 300
    color: Core.Theme.surface
    radius: Core.Theme.radius

    border.color: Core.Theme.border
    border.width: Core.Theme.borderWidth

    Image {
        anchors.fill: parent
        source: Services.MediaService.trackArtUrl || ""
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        opacity: 0.3
    }

    // Spectrum visualizer (bottom-aligned, behind controls)
    Row {
        id: spectrumRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Core.Theme.marginS
        height: 80
        spacing: 1
        opacity: 0.4

        Repeater {
            model: Services.SpectrumService.values.length || 0

            Rectangle {
                required property int index
                width: (spectrumRow.width - (spectrumRow.spacing * ((Services.SpectrumService.values.length || 1) - 1))) / (Services.SpectrumService.values.length || 1)
                height: Math.max(2, (Services.SpectrumService.values[index] || 0) * spectrumRow.height)
                anchors.bottom: parent.bottom
                radius: 1
                color: Core.Theme.green

                Behavior on height {
                    NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
                }
            }
        }
    }

    Component.onCompleted: Services.SpectrumService.registerComponent("mediaplayer")
    Component.onDestruction: Services.SpectrumService.unregisterComponent("mediaplayer")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        spacing: 4

        // Track info
        Text {
            Layout.fillWidth: true
            text: Services.MediaService.trackTitle || "~"
            color: Core.Theme.fg
            font.pixelSize: Core.Theme.fontSize + 4
            font.family: Core.Theme.fontFamily
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: (Services.MediaService.trackArtistDense || " ")
            color: Core.Theme.textMuted
            font.pixelSize: Core.Theme.fontSize
            font.family: Core.Theme.fontFamily
            elide: Text.ElideRight
            visible: text !== ""
        }

        Item { Layout.fillHeight: true }

        // Volume slider
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Core.Theme.marginM
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                width: 250
                height: 6
                radius: Core.Theme.radius
                color: Core.Theme.border

                Rectangle {
                    width: parent.width * Services.MediaService.volume
                    height: parent.height
                    radius: parent.radius
                    color: Core.Theme.green
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        Services.MediaService.setVolume(mouse.x / width)
                    }
                    onPositionChanged: mouse => {
                        if (pressed) Services.MediaService.setVolume(mouse.x / width)
                    }
                }
            }
        }

        // Controls row
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Core.Theme.marginL

            // Shuffle
            Text {
                text: "󰒝"
                color: Services.MediaService.shuffle ? Core.Theme.green : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.toggleShuffle()
                }
            }

            // Previous
            Text {
                text: "󰒮"
                color: Services.MediaService.canGoPrevious ? Core.Theme.fg : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize + 4
                font.family: Core.Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.previous()
                }
            }

            // Play/Pause
            Text {
                text: Services.MediaService.isPlaying ? "󰏤" : "󰐊"
                color: Core.Theme.green
                font.pixelSize: Core.Theme.fontSize + 8
                font.family: Core.Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.playPause()
                }
            }

            // Next
            Text {
                text: "󰒭"
                color: Services.MediaService.canGoNext ? Core.Theme.fg : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize + 4
                font.family: Core.Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.next()
                }
            }

            // Loop
            Text {
                text: {
                    switch (Services.MediaService.loopState) {
                        case 2: return "󰑘"  // Track
                        case 1: return "󰑖"  // Playlist
                        default: return "󰑗" // None
                    }
                }
                color: Services.MediaService.loopState !== 0 ? Core.Theme.green : Core.Theme.textMuted
                font.pixelSize: Core.Theme.fontSize
                font.family: Core.Theme.fontFamily
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.cycleLoop()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            
            Rectangle {
                height: 20
                width: 60
                color: Core.Theme.surface
                radius: Core.Theme.radius

                border.color: Core.Theme.border
                border.width: 2

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.MediaService.switchPlayer()
                }
            }
        }

    }
}