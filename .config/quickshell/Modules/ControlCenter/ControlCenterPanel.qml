import QtQuick
import QtQuick.Layouts
import "../../core" as Core
import "../../Services" as Services
import "../../widgets" as Widgets 

Rectangle {
    id: controlCenterPanel

    width: Core.Theme.controlCenterPanelWidth
    height: Core.Theme.controlCenterPanelHeight
    bottomLeftRadius: Core.Theme.radius
    color: Core.Theme.bg

    anchors {
        top: parent.top
        right: parent.right
    }

    // Block dim click-through
    MouseArea { anchors.fill: parent }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Core.Theme.marginM
        spacing: 8

        // avatar, power off, reboot, lockscreen
        Widgets.ControlCenterProfile { }
        
        // performance statistics
        Widgets.ControlCenterStatistics { }

        // ── Media Player ──
        Widgets.ControlCenterMediaPlayer { }

        
        Widgets.ControlCenterNetworkManager { }

        Item { Layout.fillHeight: true }
    }
    
}
