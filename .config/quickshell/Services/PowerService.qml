pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string profile: ""
    property string previousProfile: "balanced"
    readonly property bool powerSaving: profile === "power-saver"
    property string error: ""
    property string displayError: ""
    readonly property bool busy: setProfileProc.running

    readonly property string service: "org.freedesktop.UPower.PowerProfiles"
    readonly property string servicePath: "/org/freedesktop/UPower/PowerProfiles"

    onProfileChanged: displayPolicyTimer.restart()

    Timer {
        id: displayPolicyTimer
        interval: 100
        onTriggered: {
            if (displayPolicyProc.running) { restart(); return }
            root.displayError = ""
            displayPolicyProc.running = true
        }
    }

    Process {
        id: displayPolicyProc
        command: ["/usr/bin/python3", Quickshell.env("HOME") + "/dotfiles/scripts/display_power.py"]
        stderr: SplitParser {
            onRead: data => {
                if (data.trim()) root.displayError = data.trim()
            }
        }
    }

    function refresh() {
        if (!readProfileProc.running && !busy) readProfileProc.running = true
    }

    function toggle() {
        if (!available || busy || readProfileProc.running) return
        error = ""
        // The daemon authorizes active desktop sessions through polkit.
        // Use D-Bus directly so Conda's Python cannot break powerprofilesctl.
        setProfileProc.command = ["/usr/bin/busctl", "--system", "--timeout=5s",
            "set-property", service, servicePath, service, "ActiveProfile", "s",
            powerSaving ? previousProfile : "power-saver"]
        setProfileProc.running = true
    }

    Process {
        id: readProfileProc
        command: ["/usr/bin/busctl", "--system", "--timeout=5s", "--json=short",
            "get-property", root.service, root.servicePath, root.service, "ActiveProfile"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) return
                var result = JSON.parse(text)
                var profile = result.data
                if (["power-saver", "balanced", "performance"].indexOf(profile) < 0) return
                root.profile = profile
                if (profile !== "power-saver") root.previousProfile = profile
            }
        }
        onExited: code => { root.available = code === 0 }
    }

    Process {
        id: setProfileProc
        stderr: SplitParser {
            onRead: data => {
                if (data.trim()) root.error = "Could not change power profile: " + data.trim()
            }
        }
        onExited: code => {
            if (code === 0) root.error = ""
            else if (!root.error)
                root.error = "Could not change power profile. Check that your desktop session is active and unlocked."
            // Let Process clear its running state before starting the readback.
            Qt.callLater(root.refresh)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
