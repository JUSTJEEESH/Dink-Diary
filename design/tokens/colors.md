# Dink Diary · Color Tokens
*Locked direction: 1a "Night Match, athletic". Dark-first; light mode deferred.*

## Semantic tokens

| Token | Hex | Role | Contrast vs surface |
|---|---|---|---|
| `surface` | `#0A0E14` | Base canvas, court at night | — |
| `surfaceElevated` | `#141A24` | Cards, sheets, rows | — |
| `surfacePressed` | `#1C2432` | Pressed fill (surface +1 step) | — |
| `textPrimary` | `#F5F2EA` | Warm off-white, all primary copy | 17.4:1 AAA |
| `textSecondary` | `#9AA3B2` | Labels, metadata, captions | 7.6:1 AA |
| `accentWin` (brand) | `#D4F53C` | Optic ball. Wins, streaks-adjacent, CTAs, "us" on watch | 15.6:1 AAA |
| `accentWinPressed` | `#AECB2B` | Pressed fill of optic CTAs (-12% lightness) | — |
| `accentLoss` | `#FF6B5E` | Coral. Losses and nemesis moments ONLY | 6.9:1 AA |
| `streak` | `#FFD60A` | Hot hand, milestones | 13.7:1 AAA |
| `courtBlue` | `#4C8DFF` | Links, informational data (weather, HR) | 6.1:1 AA |
| `kitchenGreen` | `#3ECF8E` | Secondary data, health stats (min, cal) | 9.7:1 AAA |
| `hairline` | `rgba(245,242,234,0.10)` | Dividers, borders | — |
| `motifLine` | `rgba(212,245,60,0.28)` | Kitchen-line motif (see components.md) | decorative |

On `surfaceElevated`: textPrimary 15.7:1, textSecondary 6.9:1. All pass WCAG AA at every size used.

## Usage rules (intent)
- **Coral is sacred.** `accentLoss` appears only on loss pills, nemesis cards, and nemesis metadata. Never on health data, never on the Watch scoring face, never as a generic "error red".
- **Optic means us/win.** On the watch, the wearer's score is always `accentWin`; opponents are `textPrimary`. In lists, W pills are optic-filled with `surface`-colored text; L pills are coral text on `rgba(255,107,94,0.14)`.
- **Records are never framed negatively.** A losing record renders in `textPrimary` (neutral), a winning record in `accentWin`. Nothing renders a record in coral except the nemesis "against" stat.
- **Win/loss pill recipe:** W = bg `#D4F53C`, text `#0A0E14`. L = bg `rgba(255,107,94,0.14)`, text `#FF6B5E`.
- **Tinted chips:** informational chips use their accent at 14% alpha bg with the accent as text (e.g. weather = courtBlue).
- **Avatar tints:** partner avatars use an accent at 16–25% alpha bg with the accent as glyph color. Coral tint is reserved for the nemesis.
- **Share-card gradient:** `linear-gradient(180deg, #10182A 0%, #0A0E14 65%)` so stories don't read as pure black in feeds.

## watchOS exception
The wrist canvas is **pure `#000000`**, not `surface`. True-black OLED for maximum sun contrast and battery in always-on. `surfaceElevated` tiles keep `#141A24` on the wrist. All other tokens unchanged.

## SwiftUI notes
- Define in an asset catalog as Any/Dark identical (dark-first); add light variants later without touching call sites.
- Name them exactly as the tokens above (`.surface`, `.accentWin`…) so `/design-sync` diffs cleanly.
