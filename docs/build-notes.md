# Build notes

## Capabilities / entitlements roadmap

The app requests no special capabilities until the milestone that uses them, so
early builds sign with a bare profile and just run. When each milestone lands,
re-create the entitlements file, add `CODE_SIGN_ENTITLEMENTS` back to the target
xcconfig, and enable the capability on the App ID (automatic signing handles
most; WeatherKit needs a manual portal checkbox).

### M3 — HealthKit (iOS + Watch)

`Config/DinkDiary.entitlements` and `Config/DinkDiaryWatch.entitlements`:

```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

Re-enable `CODE_SIGN_ENTITLEMENTS` in `Config/iOS.xcconfig` and `Config/Watch.xcconfig`.

### M4 — WeatherKit (iOS)

```xml
<key>com.apple.developer.weatherkit</key>
<true/>
```

Manual one-time step: developer.apple.com → Identifiers → the app's App ID →
enable WeatherKit → Save. Can take up to ~30 min to return data.

### M6 — iCloud / CloudKit + Push (iOS)

```xml
<key>com.apple.developer.icloud-services</key>
<array><string>CloudKit</string></array>
<key>com.apple.developer.icloud-container-identifiers</key>
<array><string>iCloud.$(DD_BUNDLE_ID_BASE)</string></array>
<key>aps-environment</key>
<string>development</string>
```

## If signing errors persist after a config change

Xcode caches capability/signing state in DerivedData and replays stale errors
even after the project is clean. To force a fresh read:

1. Quit Xcode completely.
2. `rm -rf ~/Library/Developer/Xcode/DerivedData/DinkDiary-*`
3. Reopen the project, Product → Clean Build Folder (Shift+Cmd+K), then Run.

The Simulator needs no signing at all, so an iPhone 16 Simulator destination
sidesteps all provisioning/PLA errors.
