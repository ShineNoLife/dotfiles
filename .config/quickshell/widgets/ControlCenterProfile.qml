import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../core" as Core 

Rectangle {
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 40
    color: Core.Theme.surface
    radius: Core.Theme.radius

    border.color: Core.Theme.border
    border.width: Core.Theme.borderWidth

    RowLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        Layout.alignment: AlignHCenter
        
        // profile
        ClippingRectangle {
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

            Image {
                anchors.fill: parent
                source: "../icons/profile.png"
                fillMode: Image.PreserveAspectCrop
            }
        }

        Item { Layout.fillWidth: true }

        // reload
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
                color: Core.Theme.blue
                text: "󰑓"
                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.reload(false)
            }
        }

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