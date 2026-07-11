# ii — Custom Quickshell & Hyprland Desktop Environment

A customized desktop shell environment built with **Quickshell**, **QML**, and **Hyprland**, featuring Material 3 theming, real-time synchronized lyrics, and dynamic widgets.

> **Original Source**: Based on [end-4/dots-hyprland (`dots/.config/quickshell/ii`)](https://github.com/end-4/dots-hyprland/tree/main/dots/.config/quickshell/ii).

---

## Key Modifications & New Features

Below is a breakdown of the enhancements and features introduced on top of the original `end-4/dots-hyprland` configuration.

### 1. 🎵 Real-Time Synchronized Lyrics (`LyricsService.qml`)
- **LRCLIB Integration (Spotify Only)**: Added a dedicated `LyricsService.qml` singleton that queries [LRCLIB](https://lrclib.net/) for synchronized timecoded (`.lrc`) lyrics for **Spotify**.
- **Live Top Bar Streaming**: Displays live synchronized lyrics directly in the top bar (`Media.qml`) as the Spotify track plays.
- **Lyric Caching**: Caches fetched lyrics in memory to avoid repeated queries across track changes.

### 2. 🖥️ Redesigned Top Bar & Interactive Media Pill (`BarContent.qml` & `Media.qml`)
- **Interactive Media Pill**:
  - Replaced the previous left bar widgets with a unified `Media.qml` pill integrated with **Spotify**.
  - Dynamically switches between the track title/artist (when paused) and live synchronized lyrics (when playing).
  - Displays remaining track duration (`-MM:SS`).
  - When no media player is running, displays an inspirational quote (`"Everything happens for a reason"`) with an `auto_awesome` sparkle icon.
- **Live Wave Visualizer**:
  - Embedded `WaveVisualizer` directly into the background of the Media pill, animating in sync with audio playback.
- **Mouse Gestures**:
  - **Left Click**: Opens Media Controls popup (or Left Sidebar if no player is active).
  - **Double Click**: Toggles Left Sidebar.
  - **Middle Click**: Play / Pause toggle.
  - **Scroll / Back / Forward**: Next / Previous track navigation.
- **Streamlined Layout (`BarContent.qml`)**:
  - **Left**: Interactive Spotify Media Pill & Live Lyrics.
  - **Center**: Workspace switcher (`Workspaces.qml`).
  - **Right**: Consolidated system cluster (Resources/Stats, Utility Buttons, Clock/Date + Weather, System Tray, and Right Sidebar toggle).

---

## Repository Structure

```
├── GlobalStates.qml             # Global shell state management
├── shell.qml                    # Quickshell root application entry point
├── settings.qml                 # Settings interface
├── welcome.qml                  # First run / onboarding experience
├── modules/
│   ├── common/
│   │   └── widgets/             # Core UI components (WaveVisualizer, NotificationItem, etc.)
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
- Synchronized lyrics provided via **[LRCLIB](https://lrclib.net/)**.
