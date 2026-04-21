import QtQuick
import QtQuick.Layouts
import "../../core" as Core 
import "../../widgets" as Widgets

RowLayout {
    anchors.fill: parent
    spacing: 0

    // Left spacer
    Item { Layout.preferredWidth: Core.Theme.marginM }

    // Arch icon
    Item {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20
        Image {
            anchors.fill: parent
            source: "file:///home/shinenolife/.config/quickshell/icons/arch-everforest-blue.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Item { Layout.preferredWidth: Core.Theme.marginM }

    // Workspaces
    Widgets.Workspaces {}

    // Separator
    Rectangle {
        Layout.preferredWidth: 2
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: Core.Theme.marginM
        Layout.rightMargin: Core.Theme.marginM
        color: Core.Theme.border
    }

    // Active window title
    Widgets.BarActiveWindow {
        Layout.fillWidth: true
    }

    // Clock
    Widgets.BarClock {
        Layout.rightMargin: Core.Theme.marginM
    }
    
    // Separator
    Rectangle {
        Layout.preferredWidth: 2
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: Core.Theme.marginM
        color: Core.Theme.border
    }

    // Clock
    Widgets.BarBattery {
        Layout.rightMargin: Core.Theme.marginM
    }
    
    // Separator
    Rectangle {
        Layout.preferredWidth: 2
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: Core.Theme.marginM
        color: Core.Theme.border
    }

    // Control Center toggle
    Widgets.ControlCenterButton {}

    Item { Layout.preferredWidth: Core.Theme.marginM }
}