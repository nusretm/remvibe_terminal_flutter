# RemVibe Terminal Flutter

**Active TERM-02B Linux real-terminal checkpoint:** This `feature/term-02b-flutter-linux-real-pty` branch now runs **real interactive Bash PTYs on Ubuntu**, using the Linux-capable `remvibe_terminal` dependency pinned at `4a427180...`. The accepted TERM-01G-C Ubuntu **UI mock** test is historical; new native Bash/Flutter verification is still PENDING. See `docs/continuity/TERM_02B_LINUX_REAL_GUI.md`. No main merge, release or publication.


Reusable Flutter terminal viewer for the independent [RemVibe Terminal](https://github.com/nusretm/remvibe_terminal) Dart/ConPTY core.

**Status on feature branch (2026-11-21): TERM-01G-C scoped Flutter viewer implementation and operator acceptance PASS on Windows (real ConPTY) and Ubuntu (explicit UI mock).** No main merge, publication, release or deployment has been authorized. Real Ubuntu/Linux PTY is not supported.

## Responsibilities

This repository owns only the Flutter terminal **viewer**: xterm2-based rendering, keyboard input, scrolling and stable long-selection, clipboard copy/confirmation/paste, resize coordination, focus, per-pane xterm display state, and cleanup of each viewer's event subscription.

The planned public API is:

```dart
RemVibeTerminalWidget(handler: terminalHandler)
```

The handler's neutral contract is owned by [remvibe_terminal](https://github.com/nusretm/remvibe_terminal). It is implemented locally by `TerminalHandlerLocal`; other consumers may supply their own handler implementations. **The widget does not create, own, or terminate the underlying PTY.** Multiple viewers may observe a PTY without creating additional terminal processes.

## Explicit boundaries

- **remvibe_terminal:** local PTY/ConPTY and process lifecycle, native code and Native Assets, TerminalSessionService, TerminalHandler types, local handler/event/replay implementation.
- **remvibe_terminal_flutter:** Flutter UI and per-pane terminal rendering only.
- **remvibe_update_center:** remote handler implementation, Networking, Server/Client/Console routing, authorization, service management, and other consumer-specific responsibilities.

Do **not** add networking, Fleet, device identity, SCM, installers, notification delivery, terminal process management, or unrelated application features to this package.

## Source and migration

The operator-accepted reference Flutter terminal implementation remains under `example/lib/terminal_widget/` in `remvibe_terminal` on the `feature/term-01g-local-multi-handler` branch. TERM-01G-C extracted its viewer to this repository with the neutral `TerminalHandler` interface, preserving approved selection, clipboard, resize and live ConPTY behavior. The original reference stays untouched.

The feature branch provides a Flutter `pubspec.yaml`, public widget export and separate `example/` application. The core dependency is pinned to its accepted TERM-01G-B feature commit so no merge into the core main branch is required. Windows verification completed before Ubuntu Flutter/UI-mock verification; both scoped checks were accepted by the operator. No automatic merge or release is implied.

## Run from a single checkout per repository

On Windows, clone this repo once at `D:\Projects\remvibe_terminal_flutter`, switch to `feature/term-01g-c-viewer-extraction`, then run `./tool/verify_windows.ps1` in PowerShell. This validates Flutter analysis/tests then starts the two-pane real ConPTY Windows Debug example. The native core comes from the pinned Git dependency; no extra verification worktree is needed.

After Windows behavior is accepted, run `bash tool/verify_ubuntu.sh` on an Ubuntu desktop with Flutter Linux prerequisites. The Ubuntu example clearly labels its **mock** event source. It tests terminal *rendering* and two independent subscriptions but not a real Linux shell. See `docs/continuity/TERM_01G_C_UBUNTU_VERIFICATION.md` for the exact gate.
