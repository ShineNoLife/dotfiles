import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../core" as Core
import "../widgets" as Widgets
import "../Modules/Bar" as Bar

PanelWindow {
    id: barSurface

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Core.Theme.barHeight
    color: Core.Theme.bg
    focusable: true
    exclusiveZone: Core.Theme.barHeight
    
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "shell-bar"

    Bar.Bar {}
}
