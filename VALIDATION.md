# Validation

- Swift 6.0 Linux: `swift test` passed all 8 core tests.
- Swift parser: all app and iOS test sources parsed successfully with `swiftc -frontend -parse`.
- `git diff --check` passed.
- Full iOS type checking, app build, simulator interactions, and the 2 iOS account tests were not run: this executor has no Xcode or iOS Simulator. Syntax parsing does not prove an iOS build succeeds.
- `project.yml` and `.github/workflows/ios.yml` provide Mac build/test configuration. CI was not run because GitHub rejected branch creation with HTTP 403, Resource not accessible by integration. No remote files were changed.
