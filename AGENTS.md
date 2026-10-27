# tsrossa Development Rules & Standards

## Communication & Formatting Standard
- Zero-Emoji Policy: Never use emojis in code, documentation, comments, commit messages, or responses. Maintain a strictly clean, professional, and technical output format.
- Documentation Integrity: Preserve all existing architectural comments and docstrings.

## SwiftUI & Compiler Constraints
- The project is compiled using Xcode Command Line Tools (`swiftc`) without `SwiftUIMacros`.
- Never use `@State` properties inside SwiftUI views.
- All reactive state must be declared as `@Published` properties on `AppViewModel.shared` or `AudioEngine.shared`.

## Audio Engine & CoreAudio Threading
- Never invoke CoreAudio HAL mutations, device queries, or C++ audio sink methods synchronously on the main thread.
- All CoreAudio operations must be dispatched to `AudioEngine.shared.engineQueue` (`com.yuka.tsrossa.coreaudio.hal`).
- Maintain bit-perfect integrity: POSIX `mlock()` memory pinning for decoded linear PCM buffers, zero sample-rate conversion, and Exclusive Hog Mode support.

## Build and Deployment
- macOS builds are executed via `./desktop/build_mac.sh`.
- When updating `/Applications/tsrossa.app`, always clear quarantine attributes (`xattr -cr`) and perform ad-hoc code signing (`codesign --force --deep -s -`) to prevent LaunchServices error -54.
- Never push commits or tags to the remote GitHub repository without explicit user instructions.
