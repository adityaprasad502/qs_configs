# ii — Custom Quickshell & Hyprland Desktop Environment

A customized desktop shell environment built with **Quickshell**, **QML**, and **Hyprland**, featuring Material 3 theming, real-time synchronized lyrics, and dynamic widgets.

> **Original Source**: Based on [end-4/dots-hyprland (`dots/.config/quickshell/ii`)](https://github.com/end-4/dots-hyprland/tree/main/dots/.config/quickshell/ii).

---

## Key Modifications & New Features

Below is a breakdown of the enhancements and features introduced on top of the original `end-4/dots-hyprland` configuration.

### 1. 🎵 Real-Time Synchronized Lyrics (`LyricsService.qml`)
- **LRCLIB Integration (Spotify Only)**: Added a dedicated `LyricsService.qml` singleton that queries [LRCLIB](https://lrclib.net/) for synchronized timecoded (`.lrc`) lyrics for **Spotify**.
- **Deterministic Multi-Line Pairing**: Uses a single-pass disjoint-pair algorithm so adjacent short lyric lines join cleanly into natural phrases (`"Line 1 • Line 2"`) without ever overlapping or repeating lines.
- **Live Upcoming Phrase Preview**: Streams the current sung phrase to the top bar (`Media.qml`) while showing the upcoming lyric line centered inside the Media Controls popup island (`PlayerControl.qml`).
- **Smart Status States**: Automatically displays `"Fetching lyrics…"` while loading and `"No lyrics available"` / `"• No lyrics"` when a track has no synced lyrics.
- **Performance Optimized**: Eliminates timer closures and prevents redundant QML property updates (`currentLyricLine !== newCurrentLine`) to save CPU and battery.

### 2. 🖥️ Redesigned Top Bar & Media Controls Popup Island (`BarContent.qml`, `Media.qml` & `PlayerControl.qml`)
- **Interactive Top Bar Media Pill (`Media.qml`)**:
  - Dynamically switches between the cleaned track title/artist (when paused or instrumental) and live synchronized lyrics (when playing).
  - Strips hyphenated suffixes (`- From ...`, `- Official ...`, `- Remastered ...`) and trailing bracket tags for ultra-clean top bar metadata.
  - When no media player is running, displays an inspirational quote (`"Everything happens for a reason"`) with an `auto_awesome` sparkle icon.
- **Enhanced Media Controls Popup Island (`PlayerControl.qml`)**:
  - **Full Title Looping Marquee**: Displays full uncleaned track titles, scrolling long titles smoothly in a continuous looping marquee while deduplicating single album subtitles.
  - **30 FPS Interpolated Seekbar**: Real-time 30 FPS seekbar interpolation bridges 1-second MPRIS D-Bus updates for butter-smooth progress, automatically pausing when closed.
  - **Symmetrical Split-Time Layout**: Elapsed time (`trackTimeLeft`) and total duration (`trackTimeRight`) frame the seekbar with fixed `44px` widths so layout elements stay perfectly centered.
- **Live Wave Visualizer (`WaveVisualizer.qml`)**:
  - Embedded `WaveVisualizer` directly into the background of the Media pill and player controls with non-linear power curve scaling (`Math.pow(norm, 0.72)`) for balanced reactivity across soft and heavy music.
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
