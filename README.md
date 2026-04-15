<div align="center">

# Witz Lyte

### The free way to unlock 1600 nits on your Mac — and dim below the OS floor.

A tiny, free, open-source macOS menu-bar app that pushes your MacBook Pro's Liquid Retina XDR or Pro Display XDR panel past the 500-nit SDR ceiling using Apple's native EDR pipeline — then dims it below the OS's 0% floor with the same overlay. No gamma hacks, no private APIs, no display risk.

> **Free alternative to Vivid, BrightIntosh, and Lunar's XDR mode.**

<br />

## [⬇ Download Witz Lyte for Mac](https://github.com/ZipLyne-Agency/WitzLyte/releases/latest/download/Witz-Lyte.zip)

<sub>Free · No sign-up · macOS 14 Sonoma or later · Apple Silicon</sub>

<br />

[![Download](https://img.shields.io/github/v/release/ZipLyne-Agency/WitzLyte?color=FF2E63&label=Download&style=for-the-badge)](https://github.com/ZipLyne-Agency/WitzLyte/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-000000.svg?style=for-the-badge)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-14%2B-111111?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Required-7A5FFF?style=for-the-badge)](https://www.apple.com/mac/m5/)

<br />

**Crafted by [ZipLyne](https://ziplyne.agency)**

[![ZipLyne](https://img.shields.io/badge/made%20by-ziplyne.agency-FF2E63?style=for-the-badge)](https://ziplyne.agency)

[Install](#how-to-install) · [Requirements](#requirements) · [How it works](#how-it-works) · [Safety](#is-it-safe) · [FAQ](#faq)

</div>

---

## How to install

### For anyone (no Terminal needed)

1. **[Click here to download Witz-Lyte.zip](https://github.com/ZipLyne-Agency/WitzLyte/releases/latest/download/Witz-Lyte.zip)**
2. Open the downloaded zip — it unpacks to **Witz Lyte.app**.
3. Drag **Witz Lyte.app** into your **Applications** folder.
4. **The first time you open it:** right-click (or `Control`+click) **Witz Lyte.app** → **Open** → **Open** in the dialog. You only need to do this once — macOS treats free apps like this cautiously until you approve them.
5. Look for the **☀️ sun icon** in your menu bar (top-right of your screen).
6. Click the icon → **Enable Witz Lyte**, then drag the slider to make your screen brighter (or dimmer).

That's it. No account, no payment, no subscription, nothing to configure.

### For developers (build from source)

```bash
git clone https://github.com/ZipLyne-Agency/WitzLyte.git
cd WitzLyte
./build.sh
mv "dist/Witz Lyte.app" /Applications/
open "/Applications/Witz Lyte.app"
```

Requires Xcode Command Line Tools (`xcode-select --install`).

---

## Requirements

> **TL;DR — You need a MacBook Pro (M1 or later) or a Pro Display XDR. Intel Macs and MacBook Airs get a smaller boost. MacBook Pros with nano-texture glass are fully supported.**

### Minimum

| Requirement | Minimum |
|---|---|
| **Mac chip** | Apple Silicon M1 or later *(Intel not supported)* |
| **macOS** | 14.0 Sonoma or later |
| **Display** | Any display reporting EDR headroom > 1.0 *(boost level varies — see table below)* |
| **RAM / Storage** | No meaningful requirement — Witz Lyte uses < 50 MB RAM at idle |

### Display compatibility

The brightness boost you get depends entirely on your display's EDR headroom. macOS reports this at runtime — Witz Lyte reads it and hard-clamps the slider so you can never exceed hardware spec.

| Display | Mac Required | Peak Brightness | Boost Level | Notes |
|---|---|---|---|---|
| MacBook Pro 14" / 16" Liquid Retina XDR | M1 Pro/Max · M2 Pro/Max · M3/Pro/Max · M4/Pro/Max · **M5 Max** | **1600 nits** | **Full — 3.2×** | Best experience. Nano-texture supported. |
| Apple Pro Display XDR | Any Apple Silicon Mac | **1600 nits** | **Full — 3.2×** | Reference mode unaffected. |
| MacBook Air 15" (M2 / M3 / M4) | — | ~800 nits | Partial — ~1.6× | Real improvement, not full XDR |
| MacBook Air 13" (M1 / M2 / M3 / M4) | — | ~600 nits | Partial — ~1.5× | Noticeable outdoor boost |
| MacBook Pro 13" (M1 / M2) | — | ~600 nits | Partial — ~1.5× | Non-XDR panel |
| iMac 24" (M1 / M3 / M4) | — | 500 nits | None — 1.0× | Standard Retina, no EDR headroom |
| Apple Studio Display | Any | 600 nits | None — 1.0× | Reports zero EDR headroom to macOS |
| Third-party HDR monitor | Any Apple Silicon | Varies | Varies | Works when macOS reports EDR headroom > 1.0 |
| **Intel Mac (any model)** | — | — | **Not supported** | EDR pipeline requires Apple Silicon |

> **How to check your headroom:** Open Terminal and run:
> ```swift
> swift -e "import Cocoa; NSScreen.screens.forEach { print($0.localizedName, $0.maximumPotentialExtendedDynamicRangeColorComponentValue) }"
> ```
> Any value above `1.0` means Witz Lyte will work on that display. `3.2` is full XDR. `1.0` means no boost possible.

---

## Why this exists

macOS caps your 1600-nit XDR panel to ~500 nits for normal desktop content. Beautiful for color-accurate work in a dim studio — brutal outdoors, in a sunlit café, or anywhere your retinas need to overpower the environment. And if you're up at 2am, the OS brightness floor is still too bright.

Witz Lyte uses a single EDR-backed overlay to solve both problems. One slider — slide left to dim below the OS floor, slide right to boost past the SDR cap — powered by Apple's own rendering stack.

---

## Features

| | |
|---|---|
| **One unified slider** | Dim ← → Boost. Identity (1.0) in the middle snaps magnetically like macOS volume |
| **Full EDR boost** | Up to your display's reported headroom — no gamma tricks |
| **Sub-zero dim** | Goes below macOS's 0% brightness floor using multiply blend mode |
| **Global hotkeys** | `⌘⌥⇧B` toggles the overlay · `⌘⌥⇧0` resets to Normal |
| **Multi-display aware** | One overlay per screen, auto-rebuilds when displays change |
| **Battery protection** | Optional auto-disable on battery power |
| **Thermal protection** | Optional auto-disable on `.serious` / `.critical` thermal state |
| **Auto-off timer** | 15m · 30m · 1h · 2h |
| **Launch at login** | Wired to `SMAppService` — real macOS login item |
| **Nits estimate** | Live tooltip shows approximate nit output |
| **Dependency-free** | ~600 lines of Swift, single menu-bar process, < 5 MB on disk |

---

## How it works

Each screen gets a borderless, click-through, full-screen `NSWindow` at `.screenSaver` level with an `NSView` hosting a manually-configured `CAMetalLayer`:

```swift
metalLayer.pixelFormat = .rgba16Float
metalLayer.wantsExtendedDynamicRangeContent = true
metalLayer.colorspace = CGColorSpace(name: .extendedLinearDisplayP3)
metalLayer.compositingFilter = "multiplyBlendMode"
```

The layer clears to `(v, v, v, 1.0)` in extended linear Display P3. With `multiplyBlendMode`, the compositor does:

```
final_pixel = overlay_rgb × underlying_rgb
```

`v = 1.0` is identity (invisible). `v = 2.0` doubles brightness of every pixel straight into the display's reserved XDR headroom. `v = 0.5` halves every pixel — genuine sub-zero dimming below the OS brightness floor. Atomic present (`commit → waitUntilScheduled → present`) prevents compositor flashes. 1 Hz keep-alive stops macOS from disengaging EDR on idle.

No LUT manipulation, no private APIs, no SPI, no IOKit trickery.

---

## Is it safe?

**Yes.** The display's panel is rated by Apple for sustained HDR output at these levels — this is the same rendering path as HDR video. Things to know:

- Higher brightness = more power and more heat. The thermal-protection toggle handles spikes.
- The slider is hard-clamped to the OS-reported EDR headroom — you can't exceed hardware spec.
- OLED/mini-LED panels age slightly faster under sustained peak brightness over *years* of heavy use.

---

## FAQ

<details>
<summary><strong>I got a warning that the app is from an unidentified developer — is it safe?</strong></summary>

Yes. Witz Lyte is ad-hoc signed (not notarized) because notarization requires a paid Apple Developer account. The source code is right here in this repository — you can read every line yourself. To open it the first time: right-click the app → **Open** → **Open**. You only need to do this once.
</details>

<details>
<summary><strong>Does it work on an M5 Max MacBook Pro with nano-texture?</strong></summary>

Yes — fully. Nano-texture etched glass scatters some emitted light so perceived peak is marginally lower than the glossy variant, but the boost still drives the panel well past the 500-nit SDR cap toward the full 1600-nit XDR ceiling.
</details>

<details>
<summary><strong>Why does my MacBook Air get less boost than a MacBook Pro?</strong></summary>

The Air uses a standard IPS panel (Liquid Retina, not XDR) with limited HDR headroom (~1.5–1.6×). The Pro's Liquid Retina XDR panel uses mini-LED backlighting rated at 1600 nits with ~3.2× headroom. Witz Lyte reads the hardware-reported ceiling — it can't exceed what the display supports.
</details>

<details>
<summary><strong>Does it work with the Studio Display?</strong></summary>

No. The Studio Display reports zero EDR headroom to macOS. Witz Lyte detects this and the slider will have no visible effect.
</details>

<details>
<summary><strong>Does it work on Intel Macs?</strong></summary>

No. The EDR metal pipeline that Witz Lyte uses requires Apple Silicon.
</details>

<details>
<summary><strong>Will this get me banned from the App Store?</strong></summary>

Witz Lyte is distributed outside the App Store because App Store review rejects EDR-boost apps under §2.5.1. The APIs themselves are 100% public and documented. Download it here.
</details>

<details>
<summary><strong>How do I uninstall?</strong></summary>

Click the ☀️ icon → **Quit Witz Lyte**, then drag **Witz Lyte.app** from `/Applications` to the Trash. That's it.
</details>

---

## Project layout

```
WitzLyte/
├── Package.swift
├── build.sh                    # builds + bundles .app
├── Resources/
│   └── Info.plist
└── Sources/WitzLyte/
    ├── main.swift
    ├── AppDelegate.swift
    ├── Settings.swift          # UserDefaults wrapper
    ├── BrightnessController.swift
    ├── OverlayWindow.swift     # NSWindow subclass, per-screen
    ├── EDRMetalView.swift      # the actual brightness trick
    ├── MenuBarController.swift
    └── PowerMonitor.swift      # battery + thermal auto-off
```

---

## License

[MIT](LICENSE) © 2026 ZipLyne.

---

<div align="center">

### Built with care by <a href="https://ziplyne.agency">ZipLyne</a>

We design and engineer software products.<br />
[ziplyne.agency](https://ziplyne.agency)

</div>
