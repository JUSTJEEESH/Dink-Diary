# Dink Diary

iOS + Apple Watch app: the personal record of your pickleball life. Built with SwiftUI, SwiftData, HealthKit, WeatherKit, CloudKit, and StoreKit 2; no custom backend.

Design source of truth: `DESIGN-BRIEF.md` and `design/tokens/`. Product spec: `docs/concept.md`.

## One-time setup on your Mac

Requires Xcode 16 or newer.

```bash
git clone https://github.com/JUSTJEEESH/Dink-Diary.git
cd Dink-Diary
open DinkDiary.xcodeproj
```

Then, once:

1. **Edit `Config/Shared.xcconfig`** (you can open it right in Xcode's file navigator, in the Config folder):
   - `DD_BUNDLE_ID_BASE` — change to the reverse-DNS prefix your other apps use, ending in `.dinkdiary` (check any existing app in App Store Connect if unsure).
   - `DEVELOPMENT_TEAM` — your 10-character Team ID (Xcode > Settings > Accounts > your team; the ID is in the team details).
   Commit that change so it sticks.
2. Select the **DinkDiary** scheme, choose your iPhone, press **Run**. Automatic signing registers the App IDs and capabilities. The watch app installs on the paired watch automatically; there is also a **DinkDiaryWatch** scheme to run it directly.
3. **WeatherKit only:** if signing complains about WeatherKit, enable it manually on the app's App ID at [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list) (Identifiers > your app > check WeatherKit > Save). It can take up to 30 minutes to start returning data. Weather features land in a later milestone, so this can wait.

## Every cycle after that

```bash
git pull
```

Then press Run in Xcode. New source files are picked up automatically (the project uses folder-synchronized groups); you never need to touch project settings again.

Run the unit tests any time with **Cmd-U**.

## Layout

| Folder | What |
|---|---|
| `DinkDiaryShared/` | Design tokens + components, models, scoring and stats engines (compiled into both apps) |
| `DinkDiary/` | iPhone app |
| `DinkDiaryWatch/` | Watch app |
| `DinkDiaryTests/` | Unit tests |
| `Config/` | All identity and build settings, entitlements |
| `design/`, `docs/`, `DESIGN-BRIEF.md` | The locked design system and product spec |

In DEBUG builds the iPhone app has a fifth tab, **Gallery**, showing every design token and component state for visual checking against the Claude Design mocks.
