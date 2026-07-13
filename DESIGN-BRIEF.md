# Dink Diary: Brand Brief & Claude Design Playbook
*Commit this file to the repo root (or /design). It's written so Claude Design and Claude Code can both read it as source of truth.*

---

## Part 1: Brand Brief

**Product:** Dink Diary, an iOS + Apple Watch app that is the personal record of your pickleball life. Sessions, games, partners, courts, streaks, and beautiful share cards. It is a memory and identity app, NOT a coaching app, NOT a rating system.

**Tagline candidates:** "Every game, remembered." / "Your pickleball life, on record." / "Play. Tap. Remember."

**Personality (in order of priority):**
1. **Warm.** This app is about people you play with, not machines judging you. Copy sounds like your favorite doubles partner, never like a stats textbook.
2. **Stat-proud.** Numbers are celebrated, big, and confident. Think Apple Fitness rings energy: stats as trophies, not homework.
3. **Playfully premium.** Pickleball culture is fun (dinks, kitchens, pickles); the app can wink at that, but the craft level is Apple-keynote clean. Fun words, serious polish.
4. **Zero corporate, zero coach.** No "improve your game" language anywhere. Never "performance," always "your season," "your people," "your courts."

**Reference points (vibe, not copying):**
- Slopes: session cards, year-recap energy, stat presentation
- Apple Fitness: rings, celebratory milestones, dark canvas with vivid data color
- WaterLlama: charm and personality without losing utility

**Visual direction:**
- **Dark-first canvas.** Deep near-black blue (court at night under lights). Light mode exists but dark is the hero.
- **Palette:** court blue (primary surface tint), kitchen green (secondary), optic ball yellow-green (the accent; wins, streaks, CTAs), warm off-white text, coral-red reserved only for losses/nemesis moments. Ball yellow is the brand color; it should be unmistakable in the app icon and share cards.
- **Type:** SF Pro for UI; SF Rounded for big numerals and celebratory moments. Stats are set HUGE (think scoreboard), labels small and quiet.
- **Shape language:** rounded, ball-like. Continuous-corner cards, circular avatars, pill buttons. A subtle court-line motif (thin line inset on cards echoing court markings) as the signature detail.
- **Motion:** score changes tick like a scoreboard; win moments get a brief confetti-restrained bounce; nothing longer than 400ms.
- **Iconography:** SF Symbols weight-matched; custom glyphs only for paddle, ball, and kitchen line.

**Voice examples:**
- Empty state: "No games yet. Go find a fourth."
- Win streak: "7 straight. You're the problem now."
- New partner: "First game with Sarah. The chemistry test begins."
- Loss to a nemesis: "Dave again. 3 to 6 lifetime. One day."

**Hard rules:**
- Never use em dashes in any UI copy or marketing text; use commas or semicolons.
- Never use coaching language (improve, drills, technique, form).
- Stats are never framed negatively; a losing record is framed as a rivalry, not a failure.

---

## Part 2: Repo structure (so /design-sync has something to read)

```
dink-diary/
├── DESIGN-BRIEF.md          ← this file
├── docs/
│   ├── concept.md           ← the product concept doc
│   └── v1-scope.md          ← feature list, deferred list
├── design/
│   ├── tokens/              ← Claude Design exports land here
│   │   ├── colors.md
│   │   ├── typography.md
│   │   └── components.md
│   └── references/          ← screenshots of Slopes, Fitness, WaterLlama
└── (app code comes later)
```

Workflow: Session 1 in Claude Design *creates* the design system → export/commit the tokens and component specs into `design/tokens/` → from then on, run `/design-sync` from Claude Code so every future design and code task builds from the same system.

---

## Part 3: Claude Design Session Prompts

### Session 1: The Design System (do this before any screens)

> I'm building **Dink Diary**, an iOS + Apple Watch app that is the personal record of a player's pickleball life: sessions, games, partners, courts, streaks, and shareable recap cards. It is a memory and identity app, explicitly NOT a coaching or ratings app. Read the attached DESIGN-BRIEF.md and concept.md fully before designing anything.
>
> Do not design any screens yet. First, create the complete design system:
>
> 1. **Color tokens**: dark-first palette per the brief (deep court-night surface, court blue, kitchen green, optic ball yellow-green accent, warm off-white text, coral reserved for losses). Include semantic tokens (surface, surfaceElevated, textPrimary, textSecondary, accentWin, accentLoss, streak) with exact hex values and contrast ratios verified for WCAG AA.
> 2. **Typography scale**: SF Pro for UI, SF Rounded for hero numerals. Define the full scale from caption to the giant scoreboard numeral style.
> 3. **Core components**: session card, game row, stat tile, partner avatar cluster, streak badge, share card frame (9:16 and 1:1), pill button, tab bar. Each component shown in default, pressed, and empty states.
> 4. **The signature detail**: a thin inset court-line motif on cards. Show me 3 interpretations of it and recommend one.
>
> Show me 2 distinct directions for the overall system: one leaning "Apple Fitness athletic" and one leaning "warm clubhouse." Same tokens philosophy, different temperature. I'll pick one, then we refine.

### Session 2: Hero screens (after the system is locked)

> Using the locked Dink Diary design system, design these screens in order. Every screen must pass a self-check against the design system before you show me.
>
> 1. **Session recap card** (the visual signature of the whole app): Tuesday night session, 5-2 record, 3 partners, 41 min active, 780 cal, court name, weather chip. This card is what people screenshot; make it trophy-like.
> 2. **Home timeline**: scrolling feed of session cards, current streak pinned at top, one tap to start a session.
> 3. **People page**: grid of partner cards; then a partner detail page showing record together, record against, games played, last played, "chemistry" framing per the brief's voice.
> 4. **Insights**: partner chemistry ranking, nemesis tracker, day/time performance. Free tier shows 3 insights with a tasteful locked state for the rest.
> 5. **Share card**: the session recap rendered as a 9:16 story image with the Dink Diary mark small in the corner.
>
> Constraints: dark mode only for now, iPhone 15/16 Pro frame, real pickleball data in every mock (no lorem ipsum, no "Player 1"), voice per the brief. No coaching language anywhere.

### Session 3: Watch app

> Design the watchOS app for Dink Diary using the locked system, adapted for glanceability:
>
> 1. **Scoring face**: my score vs theirs, huge tap targets on top/bottom halves, server indicator, side-out vs rally mode indicator, undo via digital crown or long press. Must be readable in full sun at arm's length.
> 2. **End-of-game flow**: final score confirm → "Who was your partner?" grid of 6 recent-player faces → done. This entire flow must feel like 10 seconds.
> 3. **Session summary** on the wrist: record, games, time, heart rate.
>
> Show the scoring face in 3 layout variations and tell me which you'd bet on for mid-rally glances and why.

### Session 4: Prototype + handoff

> Turn the home timeline → session detail → partner detail flow into an interactive prototype I can put on my phone for feel-testing. Then prepare a Claude Code handoff: export the design tokens and component specs as markdown into files matching my repo's design/tokens/ structure, with design intent notes attached (spacing logic, motion specs, state behavior) so implementation preserves the details.

---

## Part 4: Iteration tips for Claude Design specifically

- Ask for **2 to 3 variations** whenever you're unsure; comparing beats describing.
- Use **inline comments** for surgical changes ("this numeral 20% bigger") and chat for global ones ("whole app 10% warmer").
- Use the **adjustment knobs** for spacing/color instead of re-prompting; it's faster and burns fewer tokens.
- Ask Claude to **review its own output** for accessibility, contrast, and hierarchy at the end of each session.
- Design shares usage limits with chat, Cowork, and Claude Code, so run design work as focused sessions, not all-day tinkering.
- When something is right, say "lock this" and have it restate the locked decision; it keeps later generations consistent.
