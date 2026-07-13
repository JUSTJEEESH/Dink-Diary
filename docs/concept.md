# Pickleball IQ (working title)
## Product Concept, v1 Spec, and Launch Plan
*The Slopes of pickleball: a beautiful personal record of every game, partner, and court in your pickleball life.*

---

## 1. Positioning

**One sentence:** Your entire pickleball life, remembered beautifully.

**What it is NOT (and why that's the strategy):**
- Not a rating system; DUPR owns that with network effects. We *display* your DUPR if you have one, we never compete with it.
- Not an AI coach; SwingVision and PB Vision own video analysis at $15/mo. Different customer job.
- Not a court finder; Pickleheads and Places2Play own discovery.
- Not a league/tournament manager; Scoreholio and Score Pickleball own events.

**The unoccupied position:** Every existing stat tool is either a dumb scorekeeper (Side Out, free, no memory) or a manual charting chore (PickleballStat, requires a sideline scorekeeper). Nobody owns "automatic personal history + delight." That is the Slopes playbook, and Slopes does $80K+/mo in a smaller sport.

**Target user:** The 3.0 to 4.0 rec player who plays 2 to 4 times a week, mostly open play and rec doubles, owns an Apple Watch, and already screenshots their stats in other apps. Not beginners, not pros.

---

## 2. The core insight competitors miss: the Session

Rec pickleball is not "a match." It's an outing: you show up to open play, play 5 to 8 games over two hours, rotate partners every game, and leave sweaty. Every competitor models single matches. We model the **Session** as the atomic unit:

```
Session (Tuesday night, Sunset Park, 2h 10m)
 ├── Game 1: w/ Mike vs Sarah & Dave, W 11-7
 ├── Game 2: w/ Sarah vs Mike & Dave, L 9-11
 ├── Game 3: w/ Dave vs Mike & Sarah, W 11-4
 ├── ...
 └── Session stats: 5-2, 3 partners, 41 min active play, 780 cal, peak HR 156
```

This unlocks the stats people actually gossip about at the kitchen line:
- "Who do I actually win with?" (per-partner win rate)
- "Who's my nemesis?" (per-opponent record)
- "Am I better at night or morning?" 
- "What's my record at each court?"

No app surfaces these today. They're cheap to compute and endlessly shareable.

---

## 3. v1 Feature Set (ship this, nothing more)

### Watch app (the capture surface)
1. **Start Session** from the wrist; begins a HealthKit workout (pickleball is a native workout type, so HR/calories are free).
2. **In-game scoring**: big tap targets, side-out AND rally scoring (2026 provisional rules), server tracking, undo. Match Side Out's simplicity or lose.
3. **End-of-game flow (the 10-second moment)**: game ends → "Who was your partner?" → tap a face from your recent-players grid → next game. This tiny flow is the entire data engine.
4. Haptic score confirmation so you never look at the watch mid-rally.

### iPhone app (the memory surface)
5. **Session timeline**: scrollable history of every outing, Slopes-style cards with weather, court, record, and health stats.
6. **People**: a card per partner/opponent with your record together and against, games played, last played. Local contacts only, no accounts, no social network in v1.
7. **Courts**: auto-detected via location, record per court.
8. **Insights tab (free tier shows 3, premium unlocks all)**: partner chemistry rankings, nemesis tracker, day/time performance, win streaks, points scored vs allowed trends.
9. **Share cards**: gorgeous session recaps and milestone cards ("100th game," "10-game win streak") designed for group chats and Instagram stories. This is the growth engine; make them the best-looking artifact in pickleball.
10. **Phone-only fallback mode** (quick score entry after each game) so non-Watch users aren't locked out, but the Watch is the hero.

### Explicitly deferred to v2+
- Android and iPad
- DUPR API integration (display-only)
- Friends/sync between users, shared sessions
- Tournament brackets, drills, coaching content of any kind
- Year in Review (build it for December; it's the biggest viral moment of the year, see Spotify Wrapped and Slopes' recap)

---

## 4. Monetization

**Freemium subscription, anchored cheap and annual:**
- **Free**: unlimited scoring, last 10 sessions of history, 3 insights, basic share card.
- **Premium, $24.99/year or $3.99/month**: unlimited history, all insights, per-partner deep stats, custom share card themes, CSV export, iCloud sync across devices.
- No lifetime tier at launch (you can add a $59.99 lifetime later as a promo lever).

Rationale: the audience skews 45+, plays year-round, and already pays for paddles that cost $200. WaterLlama and Slopes prove $20 to 30/year works when the app feels like a companion rather than a tool. Keep scoring free forever; charging for the scoreboard kills the data engine.

---

## 5. Name and ASO

"Pickleball IQ" says coaching, which is the wrong promise. Candidates that say *memory and identity*:
- **Kitchen** (the line every player lives at; short, ownable, merch-able)
- **Dink Diary** (descriptive, friendly, searchable)
- **Rally** (likely conflicts, check availability)
- **Paddle Log** / **PickleLog** (boring but keyword-rich)
- **Third Shot** (insider term, strong brand energy)

**App Store title strategy** (title + subtitle carry the most keyword weight):
- Title: `Kitchen: Pickleball Tracker`
- Subtitle: `Score, Stats & Game History`

**Primary keyword targets:** pickleball score keeper, pickleball tracker, pickleball stats, pickleball scoreboard, pickleball app, pickleball watch. Long-tail: pickleball score app apple watch, pickleball history.

**Ranking reality check:** "pickleball" head term is contested by Pickleheads/DUPR/PicklePlay with big install bases. You win on "pickleball score" and "pickleball tracker" mid-tails first, exactly how Roatán Insider ASO worked: own the specific phrase, then climb.

**Screenshots order:** 1) Watch scoring in action, 2) partner chemistry ranking, 3) session card, 4) nemesis tracker, 5) share card. Lead with the Watch; it's the differentiator and the "oh that's clever" moment.

---

## 6. Growth plan (zero ad budget)

1. **Share cards are the product's marketing department.** Every session recap has a subtle app mark. Group chats are where pickleball people live.
2. **Reddit**: r/pickleball (large, active, loves indie tools) with a build-in-public launch post; the Starter Story founders all ran this play.
3. **Facebook pickleball groups**: hundreds of local club groups; the demographic overlaps perfectly with Facebook.
4. **TestFlight beta recruited from r/pickleball**: 100 obsessive testers become your launch-day review base.
5. **Seasonal spikes**: January (resolutions), May (outdoor season), December (Year in Review v2 feature).
6. **Creator seeding**: mid-size pickleball YouTubers/TikTokers review gear constantly and rarely get app pitches.

---

## 7. Build spec for Claude Code

**Stack:** SwiftUI, watchOS companion app, SwiftData for persistence, CloudKit for sync (premium), HealthKit (workout sessions, HR, calories), WeatherKit (session conditions), CoreLocation (court detection), StoreKit 2 (subscriptions). **No custom backend.** Everything on-device + iCloud; your infrastructure cost is $0.

**Data model core:**
- `Player` (name, photo, isMe flag)
- `Court` (name, coordinate, auto-created from location)
- `Session` (date, court, weather, healthKitWorkoutID)
- `Game` (session, myPartner, opponents[2], myScore, theirScore, scoringType, serveStats optional)
- Derived stats computed, never stored.

**Build order:**
1. Data model + iPhone manual game entry (proves the model)
2. Watch scoring app + end-of-game partner picker (the hard, important part; get the interaction perfect)
3. Watch ↔ iPhone sync via WatchConnectivity + HealthKit workout wrapping
4. Sessions timeline + People + Courts screens
5. Insights engine
6. Share card renderer (SwiftUI → image)
7. StoreKit paywall + free-tier gates
8. Polish pass: haptics, animations, empty states, onboarding

**Realistic timeline for you with Claude Code:** 6 to 8 weeks to TestFlight, with week 2 spent almost entirely on the Watch scoring interaction. If that flow isn't better than Side Out, nothing else matters.

**Risks to manage:**
- Side Out is free and good at scoring; your scoring must be *equal*, your memory layer is the win.
- Rally scoring rules are in provisional flux for 2026; support both modes from day one.
- Watch-optional design matters; roughly half of players won't have one. Phone quick-entry keeps them.
- Partner picker friction is the whole ballgame. If logging a game takes more than 10 seconds, retention dies.

---

## 8. What success looks like
- Month 1 post-launch: 1,000 downloads, 4.8+ rating, 3% premium conversion
- Month 6: 10K downloads, ranked top 3 for "pickleball tracker" and "pickleball score"
- Month 12: Year in Review goes mildly viral in December; 5-figure ARR
- The comp: Slopes took years to reach $83K/mo; a realistic 18-month target here is $3 to 8K/mo, which on this leaderboard is a solid solopreneur business.
