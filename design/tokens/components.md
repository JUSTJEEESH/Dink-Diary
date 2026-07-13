# Dink Diary · Component Specs
*Locked system 1a. Spacing, motion, and state behavior are part of the spec; preserve them.*

## Spacing & shape logic
- **Grid:** 4pt base. Screen gutter 20. Card padding 18 (24 on the trophy recap card). Gap between sibling cards 10–12, between rows 8.
- **Radii (continuous corners, `.rect(cornerRadius:style:.continuous)`):** trophy card 28, session card 22, stat tile 18–20, game row 16, chips/buttons/tab bar 999 (pill). Radius steps down with nesting; a child is never rounder than its parent.
- **Shape language:** rounded, ball-like. Circular avatars, pill buttons, no sharp corners anywhere.

## The signature motif: kitchen line (locked)
1px hairline in `motifLine` rgba(212,245,60,0.28), spanning card padding-to-padding, sitting directly under the card header block, with a 1×7px center tick (the "T"). Intent: the non-volley line as quiet brand DNA.
- One per card, max. Only on cards that summarize play (session, recap, share, wrist summary).
- Empty states: dims to rgba(154,163,178,0.16).
- Never on the Watch scoring face; never as a generic divider.
- Share cards: scale up (2px line, 12px tick at 9:16 export).

## Motion (nothing exceeds 400ms)
- **Press:** scale 0.97 (0.98 on rows) + fill steps to `surfacePressed`; 120ms ease-out in, 180ms ease-out release. Optic CTAs darken to `accentWinPressed` instead of surface-stepping.
- **Score tick:** numerals roll like a scoreboard: old digit slides up 8px + fades, new one enters from below; 160ms ease-out, monospaced digits so nothing shifts.
- **Win moment:** one restrained bounce on the record numeral (scale 1 → 1.06 → 1), 320ms spring, plus haptic `.success`. No confetti systems.
- **Navigation:** screen content fades in with 10px upward drift, 240ms ease-out.
- **Watch haptics:** `.click` per score tap (never look mid-rally), `.success` on game confirm, `.retry` on undo.
- Respect Reduce Motion: replace drift/bounce with opacity fades.

## Components

### Session card
surfaceElevated, r22, p18. Header: caption date+court left, weather chip right. Kitchen line under header. Record in statLarge-fit (48pt in feed), optic if winning record, textPrimary otherwise; "N games" footnote beside baseline. Stats row: partners (textPrimary), min + cal (kitchenGreen). Pressed: scale 0.97 + surfacePressed. Empty: centered "No games yet." + "Go find a fourth.", motif dimmed.

### Trophy recap card (session detail hero)
Gradient `#10182A → #141A24`, r28, p24, 1px hairline border. 84pt record, tile trio (min / cal / peak HR on rgba(10,14,20,0.55) r16), avatar cluster + partner names. This is the screenshot artifact; nothing else on the screen competes with it.

### Game row
surfaceElevated, r16, p12×16. 32pt tinted avatar, "w/ First" headline + "vs X & Y" footnote, W/L pill right (recipe in colors.md). Pressed: scale 0.98 + surfacePressed. Empty: dashed 1px border rgba(154,163,178,0.30), dashed avatar circle, "Nothing logged tonight yet."

### Stat tile
surfaceElevated, r18-20, p14×16. Caption label above statMedium numeral. Numeral color: textPrimary default; accentWin for win-rate/celebration; kitchenGreen health; courtBlue informational. Empty: en-dash "–" in textSecondary, label stays.

### Partner avatar cluster
40pt circles, 2px `surface` ring, -10px overlap, max 3 + "+N" chip on surfacePressed. Pressed target gets optic ring. Empty: dashed circle + "Add your people."

### Streak badge
Pill, streak-at-14% bg, dot + Rounded Bold text in `streak`. Pressed: bg to 24%. Empty: dashed pill, "First W starts one."

### Pill button
Height 50–54 (64 on watch confirm), r999, optic bg + `surface` text, headline weight. Pressed: `accentWinPressed` + scale 0.97. Disabled: surfaceElevated bg + textSecondary text. Secondary variant: rgba(245,242,234,0.08) bg + textSecondary.

### Tab bar
Floating pill, rgba(20,26,36,0.92) + blur, 1px hairline border, 4 items (Sessions, People, Courts, Insights). Active item: optic glyph + label on optic-14% pill. Inactive: textSecondary. Glyphs: SF Symbols weight-matched to label; custom glyphs only for paddle, ball, kitchen line.

### Share card frames
9:16 (1080×1920) and 1:1 (1080×1080). Story gradient (colors.md), header caption + court title3, kitchen line 2px, scoreboard record in optic, stat trio, avatar cluster, mark bottom-left: 18px optic ball dot + "Dink Diary" footnote in textSecondary. Mark is never a watermark across content.

### Insights locked state (free tier)
Real rows rendered underneath, blur(6px) + 0.55 opacity; centered overlay "The rest of your story is waiting." + optic pill "Unlock all insights". Never a padlock-on-gray dead end; the data is visibly alive underneath.

## Watch-specific behavior
- Scoring face: whole-screen halves are the tap targets. **Bottom half = us** (near side of net, nearest thumb), top = them. Serve pill "SRV n" pinned top; mode chip (SIDE OUT / RALLY) pinned bottom. Undo = long-press anywhere or crown-back. Canvas pure #000 (colors.md).
- End-of-game: confirm ("That's a W." / loss: "They got that one.") → 6-face recent-partner grid, one tap → logged screen auto-advances after 2s. Target: under 10 seconds total.

## Voice guardrails (enforced in copy reviews)
No coaching language (improve, drills, technique, form). No em dashes. Losses framed as rivalry, never failure. Stats celebrated, never graded.
