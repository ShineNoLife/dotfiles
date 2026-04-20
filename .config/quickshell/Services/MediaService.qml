pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // Player selection
    property int _playerIndex: 0
    readonly property var _players: Mpris.players.values || []

    readonly property MprisPlayer currentPlayer: {
        if (_players.length === 0) return null
        var idx = Math.min(_playerIndex, _players.length - 1)
        return _players[idx]
    }

    // Cycle to the next available player
    function switchPlayer() {
        if (_players.length <= 1) return
        _playerIndex = (_playerIndex + 1) % _players.length
    }

    // Switch to a specific player by index
    function switchToPlayer(index) {
        if (index >= 0 && index < _players.length) _playerIndex = index
    }

    // Track info
    readonly property string trackTitle: currentPlayer ? (currentPlayer.trackTitle || "") : ""
    readonly property string trackArtist: currentPlayer ? (currentPlayer.trackArtist || "") : ""
    readonly property string trackAlbum: currentPlayer ? (currentPlayer.trackAlbum || "") : ""
    readonly property string trackArtUrl: currentPlayer ? (currentPlayer.trackArtUrl || "") : ""
    readonly property real trackLength: currentPlayer ? (currentPlayer.length || 0) : 0
    readonly property real trackPosition: currentPlayer ? (currentPlayer.position || 0) : 0

    // Playback state
    readonly property bool isPlaying: currentPlayer ? currentPlayer.playbackState === MprisPlaybackState.Playing : false
    readonly property bool canPlay: currentPlayer ? currentPlayer.canPlay : false
    readonly property bool canPause: currentPlayer ? currentPlayer.canPause : false
    readonly property bool canGoNext: currentPlayer ? currentPlayer.canGoNext : false
    readonly property bool canGoPrevious: currentPlayer ? currentPlayer.canGoPrevious : false

    // Shuffle & loop
    readonly property bool shuffle: currentPlayer ? !!currentPlayer.shuffle : false
    readonly property var loopState: currentPlayer ? currentPlayer.loopState : MprisLoopState.None

    readonly property string trackArtistDense: {
        if (trackArtist == "" || trackAlbum == "") return trackArtist

        return trackArtist + " [" + trackAlbum + "]"
    }

    
    // Per-player volume (0.0–1.0)
    readonly property real volume: currentPlayer ? (currentPlayer.volume || 0) : 0

    function setVolume(val) {
        if (currentPlayer) currentPlayer.volume = Math.max(0, Math.min(1.0, val))
    }

    // Controls
    function playPause() {
        if (currentPlayer) currentPlayer.togglePlaying()
    }

    function play() {
        if (currentPlayer) currentPlayer.play()
    }

    function pause() {
        if (currentPlayer) currentPlayer.pause()
    }

    function next() {
        if (currentPlayer && currentPlayer.canGoNext) currentPlayer.next()
    }

    function previous() {
        if (currentPlayer && currentPlayer.canGoPrevious) currentPlayer.previous()
    }

    function toggleShuffle() {
        if (currentPlayer) currentPlayer.shuffle = !currentPlayer.shuffle
    }

    function cycleLoop() {
        if (!currentPlayer) return
        switch (currentPlayer.loopState) {
            case MprisLoopState.None:     currentPlayer.loopState = MprisLoopState.Playlist; break
            case MprisLoopState.Playlist:  currentPlayer.loopState = MprisLoopState.Track;    break
            case MprisLoopState.Track:     currentPlayer.loopState = MprisLoopState.None;     break
        }
    }
}
