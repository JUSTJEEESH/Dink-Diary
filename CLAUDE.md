# Dink Diary

iOS + Apple Watch app: the personal record of your pickleball life. Sessions, games, partners, courts, streaks, share cards. A memory and identity app — NOT a coaching app, NOT a rating system.

## Source of truth — read before any design or UI work

1. `DESIGN-BRIEF.md` — brand personality, palette direction, type, shape language, voice, and hard rules. Binding for all UI and copy.
2. `design/tokens/colors.md`, `design/tokens/typography.md`, `design/tokens/components.md` — the locked design system exported from Claude Design. Exact values here override any general interpretation of the brief.
3. `docs/concept.md` — product concept, v1 feature set, data model, build order.

If the token files still carry an "awaiting export" note, the design system is not locked yet; follow the brief's direction and flag the gap rather than inventing token values.

## Hard rules (from the brief)

- Never use em dashes in UI copy or marketing text; use commas or semicolons.
- Never use coaching language (improve, drills, technique, form). Say "your season," "your people," "your courts" — never "performance."
- Stats are never framed negatively; a losing record is a rivalry, not a failure.
- Motion ≤ 400ms. Dark-first canvas.

## Stack (when app code lands)

SwiftUI, watchOS companion, SwiftData, CloudKit (premium sync), HealthKit, WeatherKit, CoreLocation, StoreKit 2. No custom backend. Build order lives in `docs/concept.md` §7.
