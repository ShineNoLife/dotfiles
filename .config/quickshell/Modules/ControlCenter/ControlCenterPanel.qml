import QtQuick
import QtQuick.Layouts
import "../../core" as Core
import "../../Services" as Services

Rectangle {
    id: controlCenterPanel

    width: Core.Theme.controlCenterPanelWidth
    height: Core.Theme.controlCenterPanelHeight
    radius: Core.Theme.radius
    color: Core.Theme.bg

    anchors {
        top: parent.top
        right: parent.right
        // bottom: parent.bottom
        // topMargin: Core.Theme.marginM
        // rightMargin: Core.Theme.marginM
        // bottomMargin: Core.Theme.marginM
    }

    // Block dim click-through
    MouseArea { anchors.fill: parent }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        spacing: 8

        // avatar, power off, reboot, lockscreen
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 40
            color: Core.Theme.surface
            radius: Core.Theme.radius

            RowLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.marginM
                Layout.alignment: AlignHCenter

                // profile
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                    }
                    width: height
                    color: Core.Theme.surface
                    radius: width/2

                    border.color: Core.Theme.border
                    border.width: 2
                }

                Item { Layout.fillWidth: true }

                // lock
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height
                    color: Core.Theme.surface
                    radius: width/2

                    border.color: Core.Theme.border
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        color: Core.Theme.fg
                        text: ""
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Core.ShellState.lock()
                    }
                }

                // reboot
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height
                    color: Core.Theme.surface
                    radius: width/2

                    border.color: Core.Theme.border
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        color: Core.Theme.fg
                        text: ""
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Core.ShellState.reboot()
                    }
                }

                // shutdown
                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                    }
                    width: height
                    color: Core.Theme.surface
                    radius: width/2

                    border.color: Core.Theme.border
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        color: Core.Theme.fg
                        text: "⏻"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Core.ShellState.shutdown()
                    }
                }
                
            }
        }
        
        // performance statistics
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 30
            color: Core.Theme.surface
            radius: Core.Theme.radius

            GridLayout {
                anchors.fill: parent
                anchors.margins: Core.Theme.marginM
                columns: 3

                // ── CPU ──
                Item {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        anchors.centerIn: parent
                        text: Core.ShellState.cpuUsage + "% "
                        color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                        font.pixelSize: Core.Theme.fontSize
                        font.family: Core.Theme.fontFamily
                        font.bold: true
                    }
                }

                // ── Memory ──
                Item {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        anchors.centerIn: parent
                        text: Core.ShellState.memUsage.toFixed(2) + " GB "
                        color: Core.ShellState.cpuUsage > 80 ? Core.Theme.red : Core.Theme.green
                        font.pixelSize: Core.Theme.fontSize
                        font.family: Core.Theme.fontFamily
                        font.bold: true
                    }
                }

                // ── Volume ──
                Item {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        anchors.centerIn: parent
                        text: Core.ShellState.volumeLevel + "% 󱄠"
                        color: Core.Theme.orange
                        font.pixelSize: Core.Theme.fontSize
                        font.family: Core.Theme.fontFamily
                        font.bold: true
                    }
                }

            }

        }

        // ── Media Player ──
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: 200
            color: Core.Theme.surface
            radius: Core.Theme.radius
            
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
                    text: (Services.MediaService.trackArtistDense || "")
                    color: Core.Theme.textMuted
                    font.pixelSize: Core.Theme.fontSize
                    font.family: Core.Theme.fontFamily
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                Item { Layout.fillHeight: true }

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

        Item { Layout.fillHeight: true }
    }
    
}
