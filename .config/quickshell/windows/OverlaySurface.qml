import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../core" as Core
import "../Modules/ControlCenter" as ControlCenter

PanelWindow {
    id: overlaySurface

    color: "transparent"
    surfaceFormat.opaque: false

    visible: Core.ShellState.overlayOpen
    focusable: Core.ShellState.overlayOpen
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    margins.top: Core.Theme.barHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "shell-overlay"

    // ── Dim ──
    Rectangle {
        anchors.fill: parent
        color: Core.Theme.dim

        MouseArea {
            anchors.fill: parent
            onClicked: Core.ShellState.closeAllPanels()
        }
    }

    // ── Control Center panel ──
    ControlCenter.ControlCenterPanel {
        //double negation trick to force undefined -> false 
        visible: !!Core.ShellState.openPanels["controlcenter"]
    }
}
