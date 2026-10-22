import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "../../core" as Core
import "../../widgets" as Widgets 

Rectangle {
    id: controlCenterPanel

    width: Core.Theme.controlCenterPanelWidth
    height: Math.min(Core.Theme.controlCenterPanelHeight, parent.height)
    bottomLeftRadius: Core.Theme.radius
    color: Core.Theme.bg

    anchors {
        top: parent.top
        right: parent.right
    }

    // Block dim click-through
    MouseArea { anchors.fill: parent }

    ScrollView {
        id: panelScroll
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        contentWidth: availableWidth
        contentHeight: panelContent.implicitHeight
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: panelContent
            width: panelScroll.availableWidth
            spacing: Core.Theme.marginM

            // Avatar, power off, reboot, lockscreen.
            Widgets.ControlCenterProfile { }

            Widgets.ControlCenterStatistics { }
            Widgets.ControlCenterBrightness { }
            Widgets.ControlCenterButtons { }
            Widgets.ControlCenterMediaPlayer { }
            Widgets.ControlCenterNetworkManager { }

        }
    }
    
}
