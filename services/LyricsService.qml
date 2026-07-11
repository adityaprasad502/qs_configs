pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    property string currentTrackName: ""
    property string currentArtistName: ""

    property int currentFetchId: 0
    property bool loading: false
    property string currentLyricLine: ""
    property var lyricLines: [] // Array of { time: seconds, text: string }
    property string plainLyrics: ""

    property real lastKnownPosition: 0
    property real lastKnownTimestamp: 0

    function normalizeStr(s) {
        if (!s) return "";
        return String(s).toLowerCase().replace(/[^a-z0-9]/g, "");
    }

    function findBestResult(results, targetTrack, targetArtist) {
        if (!results || !Array.isArray(results) || results.length === 0) return null;
        let normTrack = root.normalizeStr(targetTrack);
        let normArtist = root.normalizeStr(targetArtist);

        for (let i = 0; i < results.length; i++) {
            let r = results[i];
            if (!r || !r.syncedLyrics) continue;
            let rTrack = root.normalizeStr(r.trackName);
            let rArtist = root.normalizeStr(r.artistName);
            if ((rTrack === normTrack || (normTrack.length > 2 && (rTrack.includes(normTrack) || normTrack.includes(rTrack)))) &&
                (!normArtist || rArtist.includes(normArtist) || normArtist.includes(rArtist))) {
                return r;
            }
        }

        for (let i = 0; i < results.length; i++) {
            let r = results[i];
            if (!r || !r.syncedLyrics) continue;
            let rTrack = root.normalizeStr(r.trackName);
            if (rTrack === normTrack || (normTrack.length > 2 && (rTrack.includes(normTrack) || normTrack.includes(rTrack)))) {
                return r;
            }
        }

        for (let i = 0; i < results.length; i++) {
            if (results[i] && results[i].syncedLyrics) return results[i];
        }
        return results[0];
    }

    property var lyricCache: ({})

    function fetchLyrics(track, artist) {
        root.currentFetchId++;
        let myFetchId = root.currentFetchId;

        if (!track || track === "") {
            root.lyricLines = [];
            root.plainLyrics = "";
            root.currentLyricLine = "";
            return;
        }
        root.loading = true;
        root.lyricLines = [];
        root.plainLyrics = "";
        root.currentLyricLine = "";

        let cleanTrack = StringUtils.cleanMusicTitle(track);
        let cleanArtist = artist || "";
        let cacheKey = (cleanTrack + "___" + cleanArtist).toLowerCase();

        if (root.lyricCache[cacheKey]) {
            root.loading = false;
            root.parseLyricsResponse(root.lyricCache[cacheKey]);
            return;
        }

        let query = `${cleanTrack} ${cleanArtist}`.trim();
        let url = `https://lrclib.net/api/search?q=${encodeURIComponent(query)}`;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (myFetchId !== root.currentFetchId) return;
                root.loading = false;
                if (xhr.status === 200) {
                    try {
                        var results = JSON.parse(xhr.responseText);
                        let best = root.findBestResult(results, cleanTrack, cleanArtist);
                        if (best) {
                            root.lyricCache[cacheKey] = best;
                            root.parseLyricsResponse(best);
                        }
                    } catch(e) {}
                }
            }
        };
        xhr.open("GET", url, true);
        xhr.send();
    }

    function parseLyricsResponse(data) {
        if (!data) return;
        root.plainLyrics = data.plainLyrics || "";
        let synced = data.syncedLyrics;
        if (synced && synced.length > 0) {
            let lines = synced.split("\n");
            let parsed = [];
            let regex = /\[(\d+:\d+(?:\.\d+)?)\](.*)/;
            for (let i = 0; i < lines.length; i++) {
                let match = regex.exec(lines[i]);
                if (match) {
                    let timeParts = match[1].split(":");
                    let timeSec = (parseFloat(timeParts[0]) || 0) * 60.0 + (parseFloat(timeParts[1]) || 0);
                    let text = match[2].trim();
                    if (text.length > 0) {
                        parsed.push({ time: timeSec, text: text });
                    }
                }
            }
            root.lyricLines = parsed;
        }
    }

    function isSpotifyPlayer(player) {
        if (!player) return false;
        let id = (player.identity || "").toLowerCase();
        let entry = (player.desktopEntry || "").toLowerCase();
        let bus = (player.busName || "").toLowerCase();
        return id.includes("spotify") || entry.includes("spotify") || bus.includes("spotify");
    }

    function syncTrackChange() {
        let newTitle = activePlayer?.trackTitle || "";
        let newArtist = activePlayer?.trackArtist || "";
        if (newTitle !== root.currentTrackName || newArtist !== root.currentArtistName) {
            root.currentTrackName = newTitle;
            root.currentArtistName = newArtist;
            root.lastKnownPosition = activePlayer?.position || 0;
            root.lastKnownTimestamp = Date.now();
            if (root.isSpotifyPlayer(activePlayer)) {
                root.fetchLyrics(root.currentTrackName, root.currentArtistName);
            } else {
                root.lyricLines = [];
                root.plainLyrics = "";
                root.currentLyricLine = "";
            }
        }
    }

    Connections {
        target: activePlayer
        function onTrackTitleChanged() { root.syncTrackChange(); }
        function onTrackArtistChanged() { root.syncTrackChange(); }
        function onPositionChanged() {
            root.lastKnownPosition = activePlayer?.position || 0;
            root.lastKnownTimestamp = Date.now();
        }
    }

    Connections {
        target: MprisController
        function onActivePlayerChanged() { root.syncTrackChange(); }
    }

    Timer {
        interval: 100
        repeat: true
        running: activePlayer?.playbackState === MprisPlaybackState.Playing && root.lyricLines.length > 0
        onTriggered: {
            let pos = activePlayer?.position || 0;
            let elapsedSec = (Date.now() - root.lastKnownTimestamp) / 1000.0;

            if (Math.abs(pos - (root.lastKnownPosition + elapsedSec)) > 1.5) {
                root.lastKnownPosition = pos;
                root.lastKnownTimestamp = Date.now();
                elapsedSec = 0;
            }

            let currentPos = root.lastKnownPosition + elapsedSec;
            let audioSyncPos = Math.max(0, currentPos - 0.35);

            let lines = root.lyricLines;
            let currentText = "";
            for (let i = 0; i < lines.length; i++) {
                if (audioSyncPos >= lines[i].time) {
                    currentText = lines[i].text;
                } else {
                    break;
                }
            }
            root.currentLyricLine = currentText;
        }
    }

    Component.onCompleted: {
        root.syncTrackChange();
    }
}
