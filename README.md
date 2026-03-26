<div align="center">

<img src="docklock-smol.svg" width="72" height="72" alt="DockLock" />

# DockLock

**Keep your Dock where you put it.**

DockLock stops your Dock from jumping monitors every time your cursor grazes the bottom of the screen.

[**See the demo →**](https://timlenardo.github.io/docklock/)&nbsp;&nbsp;·&nbsp;&nbsp;[Download](#download)&nbsp;&nbsp;·&nbsp;&nbsp;[Support ♡](https://buy.stripe.com/00w6oG8d3bdDfFaaFt1B604)

</div>

---

## What it does

On macOS with multiple monitors, the Dock hides and re-appears on whatever screen your cursor is closest to — even when you're just trying to scroll or reach the bottom of a window. It's one of the most persistent annoyances in the multi-display workflow.

DockLock fixes it. It sits quietly in your menu bar and monitors your cursor. The Dock stays on the screen you put it on, and only moves intentionally.

**→ [Watch the animated demo](https://timlenardo.github.io/docklock/)**

## Features

- **Zero config** — install it, grant accessibility access, done
- **Lightweight** — just a menu bar icon, no bloat
- **Smart detection** — tracks actual cursor intent, not just position
- **Jump counter** — see how many accidental dock jumps it's prevented
- **Free** — pay what you want

## Download

Grab the latest `.dmg` from the [Releases](https://github.com/timlenardo/docklock/releases) page.

**Requirements:** macOS (Apple Silicon + Intel)

> DockLock needs Accessibility access to monitor cursor position. You'll be prompted on first launch.

## How it works

DockLock uses the macOS Accessibility API to watch cursor movement near screen edges. When it detects the cursor crossing the bottom boundary of a non-primary screen — a pattern that almost always triggers an accidental Dock migration — it intervenes before the Dock has a chance to jump.

The whole app is a single menu bar item. No settings to configure.

## Building from source

```bash
git clone https://github.com/timlenardo/docklock
cd docklock
open docklock.xcodeproj
```

Build and run from Xcode. Requires macOS 14+ SDK.

## Support

DockLock is free. If it saves your sanity, [buy me a coffee ♡](https://buy.stripe.com/00w6oG8d3bdDfFaaFt1B604)

---

<div align="center">Made by <a href="https://github.com/timlenardo">Tim Lenardo</a></div>
