pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Output (sink)
    readonly property PwNode sink: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : true

    // Input (source)
    readonly property PwNode source: Pipewire.ready ? Pipewire.defaultAudioSource : null
    readonly property real inputVolume: source && source.audio ? source.audio.volume : 0
    readonly property bool inputMuted: source && source.audio ? source.audio.muted : true

    // Convenience percentage (0-100)
    readonly property int volumePercent: Math.round(volume * 100)
    readonly property int inputVolumePercent: Math.round(inputVolume * 100)

    // Volume icon helper
    readonly property string volumeIcon: {
        if (muted || volume <= 0.001) return "󰝟"
        if (volume <= 0.33) return "󰕿"
        if (volume <= 0.66) return "󰖀"
        return "󰕾"
    }

    // Output controls
    function setVolume(val) {
        if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1.0, val))
    }

    function increaseVolume(step) {
        setVolume(volume + (step || 0.05))
    }

    function decreaseVolume(step) {
        setVolume(volume - (step || 0.05))
    }

    function toggleMute() {
        if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
    }

    // Input controls
    function setInputVolume(val) {
        if (source && source.audio) source.audio.volume = Math.max(0, Math.min(1.0, val))
    }

    function toggleInputMute() {
        if (source && source.audio) source.audio.muted = !source.audio.muted
    }
}
