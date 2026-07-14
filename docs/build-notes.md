# Build notes

## One-time capability setup (do these in Xcode / the developer portal)

The app now uses HealthKit, WeatherKit, iCloud/CloudKit, and Push. Entitlements
are declared in `Config/DinkDiary.entitlements` (iOS) and
`Config/DinkDiaryWatch.entitlements` (watch). After pulling, do this once:

1. **Agree to the latest Program License Agreement** at developer.apple.com if
   prompted (this blocks all signing until done).
2. **Automatic signing handles most of it.** Select the DinkDiary target, then
   the DinkDiaryWatch target, and let Xcode register HealthKit, iCloud
   (CloudKit), and Push. If Signing & Capabilities shows a "Try Again" or a
   fix-it, click it.
3. **WeatherKit needs one manual step** automatic signing can't do: at
   developer.apple.com → Certificates, Identifiers & Profiles → Identifiers →
   your app's App ID → check **WeatherKit** → Save. Allow up to ~30 minutes for
   it to start returning data. Until then, weather just doesn't appear (no crash).
4. **iCloud container:** the entitlement references `iCloud.$(DD_BUNDLE_ID_BASE)`.
   Automatic signing creates it. CloudKit sync only turns on for premium users,
   and only at the launch after purchase (the container is built once per launch).

Every capability is best-effort in code: if a permission is denied or a service
isn't set up yet, that feature is simply absent, never a crash.

## What each capability powers

- **HealthKit** (watch owns the workout): the watch wraps each session in a
  `.pickleball` workout; its UUID rides the session-end payload; the phone reads
  duration, active calories, and peak heart rate back onto the session (filling
  the trophy and summary tiles). Watch-to-phone HealthKit sync has a delay, so
  the phone re-tries unfilled sessions each time it becomes active.
- **WeatherKit + CoreLocation** (phone): when a phone session starts, the app
  grabs your location, matches or creates the court, and stamps the current
  weather onto the session (the chip on the cards).
- **CloudKit** (phone, premium): SwiftData private-database mirroring across the
  user's devices.

## Before App Store submission

- Replace the placeholder Privacy URL in `PaywallView.swift`.
- Provide a real Privacy Policy and confirm HealthKit/Location usage strings
  (currently set via `INFOPLIST_KEY_*` in the xcconfigs) read well.

## If signing errors persist after a config change

Xcode caches capability/signing state in DerivedData and can replay stale errors
even after the project is clean:

1. Quit Xcode completely.
2. `rm -rf ~/Library/Developer/Xcode/DerivedData/DinkDiary-*`
3. Reopen, Product → Clean Build Folder (Shift+Cmd+K), then Run.

The Simulator needs no signing at all; an iPhone 16 Simulator sidesteps
provisioning entirely (HealthKit workout data and real WeatherKit won't be
present there, but the UI and CloudKit-off path run fine).
