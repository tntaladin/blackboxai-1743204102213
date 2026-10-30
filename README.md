# Ride Demo (UberClone)

An iOS 16+ SwiftUI passenger app demo. This is not affiliated with Uber.

## What works

- Create local accounts, sign out, and sign back in after restarting. Accounts and the session are stored in the device Keychain.
- Request location permission, or use an explicitly labelled San Francisco demo pickup when location is unavailable.
- Search places through Apple MapKit, select a destination, load a driving route, see distance/estimated travel time, and choose UberX, Uber Black, or UberXL.
- Confirm a **demo** ride, start it, complete it or cancel it. Only one active trip per account is allowed.
- Review account-specific trips after restarting. Trip history is stored as an atomic JSON file in Application Support.
- Toggle a persistent dark appearance setting.

## Run on a Mac

Requires Xcode with iOS Simulator and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open UberClone.xcodeproj
```

Select the `UberClone` scheme and an iPhone simulator, then Run. For a physical iPhone, set your development team in Signing & Capabilities and use a unique bundle identifier if needed. No Firebase credentials, API keys, or payment account are required. The generated Xcode project and Info.plist are derived from `project.yml`.

Create a new account with an email and a password of at least 8 characters. Accounts are local only; do not use a real password. If testing live location on Simulator, select a simulated location. Apple search and directions need internet; route errors have a retry button. Demo destination suggestions are in San Francisco, so choose a nearby destination when using a different real pickup.

## Tests

```sh
swift test
xcodegen generate
xcodebuild test -project UberClone.xcodeproj -scheme UberClone -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO
```

Choose an installed simulator name. Core tests cover fares, state transitions, history persistence, user isolation, duplicate bookings, invalid requests, corrupt storage, and disk write failures. iOS tests cover local account persistence, sign-in, duplicate accounts, and invalid registration. GitHub Actions runs both suites and builds the iOS app.

## Limits and next production work

This version simulates the passenger workflow. It does not dispatch real drivers, charge cards, or automatically track a moving trip. Fares are demo estimates in USD. Keychain storage is not a replacement for backend identity verification; email ownership is not verified. There is no cross-device sync or account recovery. The UI is currently English.

Production requires a backend for authentication and authorization, driver matching and tracking, server-validated pricing, notifications, payments, privacy controls, and operational support. Original Firebase references were removed because the supplied project had no Firebase configuration and its implemented services used local mocks.
