# Dink Diary · Typography
*SF Pro for UI, SF Rounded for numerals and celebration. Locked.*

## Scale

| Style | Font | Size/Line | Weight | Notes |
|---|---|---|---|---|
| `scoreboard` | SF Rounded | 96/96 | Heavy (800) | Tracking -0.02em. Share cards, watch game-over. 160pt on 9:16 export |
| `statLarge` | SF Rounded | 64/64 | Bold | Session record on recap card (84pt on trophy card is same style, size-fit) |
| `statMedium` | SF Rounded | 44/44 | Bold | Stat tiles, partner records |
| `statSmall` | SF Rounded | 28/30 | Bold | Inline stats, tile trios |
| `largeTitle` | SF Pro | 34/41 | Bold | Screen titles ("Your season") |
| `title1` | SF Pro | 28/34 | Bold | Partner names, section heroes |
| `title3` | SF Pro | 20/25 | Semibold | Card titles (court name) |
| `headline` | SF Pro | 17/22 | Semibold | Buttons, row titles, chemistry lines |
| `body` | SF Pro | 15/20 | Regular | Prose, row content |
| `footnote` | SF Pro | 13/18 | Regular | Metadata, secondary rows |
| `caption` | SF Pro | 11/13 | Medium | UPPERCASE, tracking +0.08em, always `textSecondary` |

## Watch scale (actual pt, 46mm)
- Scoring numerals: 80pt Rounded Heavy (the whole point)
- Confirm numerals: 55pt Rounded Heavy
- Buttons: 12pt Semibold minimum, 44pt+ hit targets
- Minimum text anywhere on wrist: 13pt

## Rules (intent)
- **Numerals are always SF Rounded and tabular** (`font-variant-numeric: tabular-nums` / `.monospacedDigit()`), so score ticks don't jiggle layout.
- **Stats never share a line with prose.** Big numeral, quiet caption label underneath. Labels never bold, never colored brighter than `textSecondary`.
- **Scores use hyphen separators** ("5-2", "W 11-7"). Never em dashes anywhere, in copy or UI.
- Hierarchy is size-first, not weight-first: jump scale steps rather than adding weight.
- SwiftUI: `Font.system(.largeTitle, design: .default)` for UI, `design: .rounded` for stat styles; apply `.fontWeight(.heavy)` only on scoreboard/statLarge.
