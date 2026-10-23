import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../core" as Core

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    Layout.fillHeight: true

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool batteryReady: battery.ready && battery.isPresent
    readonly property int capacity: batteryReady ? Math.round(battery.percentage * 100) : 0
    property bool tooltipVisible: false

    readonly property bool isCharging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged

    function formatDuration(seconds) {
        if (!isFinite(seconds) || seconds <= 0) return ""
        var minutes = Math.floor(seconds / 60)
        if (minutes < 1) return "Less than 1 min"
        var hours = Math.floor(minutes / 60)
        minutes %= 60
        if (hours === 0) return minutes + " min"
        return hours + " h" + (minutes > 0 ? " " + minutes + " min" : "")
    }

    readonly property string tooltipText: {
        if (!batteryReady) return "Battery estimate unavailable"
        switch (battery.state) {
        case UPowerDeviceState.Discharging:
        case UPowerDeviceState.PendingDischarge:
            var remaining = formatDuration(battery.timeToEmpty)
            return remaining ? remaining + " remaining (estimated)" : "Estimating remaining time…"
        case UPowerDeviceState.Charging:
            var untilFull = formatDuration(battery.timeToFull)
            return untilFull ? untilFull + " until full (estimated)" : "Charging — estimating time to full…"
        case UPowerDeviceState.FullyCharged:
            return "Fully charged"
        case UPowerDeviceState.PendingCharge:
            return "Plugged in — not charging"
        case UPowerDeviceState.Empty:
            return "Battery empty"
        default:
            return "Battery estimate unavailable"
        }
    }

    Accessible.name: "Battery"
    Accessible.description: (batteryReady ? capacity + "% — " : "") + tooltipText

    readonly property string batteryIcon: {
        if (isCharging) return "󰂄"
        if (capacity >= 90) return "󰁹"
        if (capacity >= 70) return "󰂀"
        if (capacity >= 50) return "󰁾"
        if (capacity >= 30) return "󰁼"
        if (capacity >= 15) return "󰁺"
        return "󰂃"
    }

    readonly property color batteryColor: {
        if (isCharging) return Core.Theme.green
        if (capacity <= 15) return Core.Theme.red
        if (capacity <= 30) return Core.Theme.orange
        return Core.Theme.fg
    }

    // ── UI ──

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Core.Theme.marginS

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.batteryIcon + " " + (root.batteryReady ? root.capacity + "%" : "—")
            color: root.batteryColor
            font.pixelSize: Core.Theme.fontSize
            font.family: Core.Theme.fontFamily
            font.bold: true
        }
    }

    HoverHandler {
        id: batteryHover
        onHoveredChanged: {
            if (!hovered) root.tooltipVisible = false
        }
    }

    Timer {
        interval: 350
        running: batteryHover.hovered
        onTriggered: root.tooltipVisible = true
    }

    // A separate surface keeps the tooltip from being clipped by the 30px bar.
    PopupWindow {
        id: tooltip
        anchor.item: root
        anchor.rect.x: Math.round((root.width - width) / 2)
        anchor.rect.y: root.height + Core.Theme.marginS
        visible: root.tooltipVisible && batteryHover.hovered
        implicitWidth: tooltipLabel.implicitWidth + Core.Theme.marginL * 2
        implicitHeight: tooltipLabel.implicitHeight + Core.Theme.marginM * 2
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Core.Theme.surface
            radius: Core.Theme.radius
            border.color: Core.Theme.border
            border.width: Core.Theme.borderWidth

            Text {
                id: tooltipLabel
                anchors.centerIn: parent
                text: root.tooltipText
                color: Core.Theme.fg
                font.family: Core.Theme.fontFamily
                font.pixelSize: Core.Theme.fontSize - 2
            }
        }
    }
}
