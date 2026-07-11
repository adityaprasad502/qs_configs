# ii — Custom Quickshell & Hyprland Desktop Environment

A customized desktop shell environment built with **Quickshell**, **QML**, and **Hyprland**, featuring Material 3 theming, real-time synchronized lyrics, and dynamic widgets.

> **Original Source**: Based on [end-4/dots-hyprland (`dots/.config/quickshell/ii`)](https://github.com/end-4/dots-hyprland/tree/main/dots/.config/quickshell/ii).

---

## Key Modifications & New Features

Below is a detailed breakdown of the enhancements and features introduced on top of the original `end-4/dots-hyprland` configuration.

### 1. 🎵 Real-Time Synchronized Lyrics (`LyricsService.qml`)
- **Spotify Support Only (`isSpotifyPlayer`)**: Synchronized lyrics fetching is restricted specifically to **Spotify** MPRIS clients. `LyricsService.qml` verifies the active player via `isSpotifyPlayer(activePlayer)`, checking if the player's `identity`, `desktopEntry`, or `busName` contains `"spotify"`. Non-Spotify players are ignored for lyrics streaming.
- **LRCLIB Integration**: Added a dedicated `LyricsService.qml` singleton that queries [LRCLIB](https://lrclib.net/) for synchronized timecoded (`.lrc`) and plain lyrics based on the current Spotify track and artist.
- **Intelligent Title Normalization**: Automatically cleans music titles (`StringUtils.cleanMusicTitle`) to strip tags like remaster suffixes or featured artists, ensuring reliable lyric matches.
- **Live Top Bar Streaming**: Displays live synchronized lyrics directly in the top bar (`Media.qml`) as the Spotify track progresses (`LyricsService.currentLyricLine`).
- **Lyric Caching**: In-memory caching minimizes API queries across track changes and repeats.

### 2. 🖥️ Redesigned Top Bar & Interactive Media Pill (`BarContent.qml` & `Media.qml`)
- **Interactive Media Pill**:
  - Replaced the previous separate left bar items with a unified, interactive `Media.qml` pill integrated with **Spotify**.
  - Dynamically switches between the Spotify track title/artist and live synchronized lyrics when music is playing.
  - Displays formatted remaining track duration (`-MM:SS`).
  - When Spotify is paused or not running, displays an inspirational quote (`"Everything happens for a reason"`) with an `auto_awesome` sparkle icon.
- **Live Wave Visualizer**:
  - Embedded `WaveVisualizer` directly into the background of the Media pill, animating in sync with Spotify audio playback.
- **Rich Mouse Gestures**:
  - **Left Click**: Opens Media Controls popup (or Left Sidebar if no player is active).
  - **Double Click**: Toggles Left Sidebar.
  - **Middle Click**: Play/Pause toggle.
  - **Forward / Back / Scroll**: Next / Previous track navigation.
- **Clean Sectional Layout (`BarContent.qml`)**:
  - **Left**: Interactive Spotify Media Pill & Live Lyrics.
  - **Center**: Centered Workspace switcher (`Workspaces.qml`).
  - **Right**: Consolidated system cluster featuring System Resources/Stats, Utility Buttons, Clock/Date + Weather, System Tray, and Right Sidebar toggle.

---

## Repository Structure

```
├── GlobalStates.qml             # Global shell state management
├── shell.qml                    # Quickshell root application entry point
├── settings.qml                 # Settings interface
├── welcome.qml                  # First run / onboarding experience
├── modules/
│   ├── common/
│   │   └── widgets/
│   │       ├── WaveVisualizer.qml
│   │       └── NotificationItem.qml
│   └── ii/
│       ├── bar/                 # Top bar components (BarContent, Media, ClockWidget, etc.)
│       └── mediaControls/       # Media control popups & player interface
├── services/
│   └── LyricsService.qml        # Spotify synchronized lyrics fetcher (LRCLIB)
├── scripts/                     # Color schemes, AI utilities, wallpaper & thumbnail helpers
└── translations/                # Locale definitions (en_US.json, etc.)
```

---

## Running & Configuration

### Launching the Shell
Start or reload the Quickshell environment with:
```bash
qs -p shell.qml
```

---

## Credits & Acknowledgements
- Original Quickshell configuration base by **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**.
- Lyrics provided via **[LRCLIB](https://lrclib.net/)**.
