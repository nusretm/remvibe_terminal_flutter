# RemVibe Terminal Flutter

Reusable Flutter terminal viewer for the independent [RemVibe Terminal](https://github.com/nusretm/remvibe_terminal) Dart/ConPTY core.

**Status:** Repository initialized. TERM-01G-C widget extraction is **planned but not implemented or operator-approved**. No Flutter package build, tests, release or publication has been completed here.

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

The existing operator-verified Flutter terminal implementation remains under the `example/lib/terminal_widget/` directory of `remvibe_terminal` on the `feature/term-01g-local-multi-handler` branch. TERM-01G-C will extract that working implementation into this repository after separate explicit operator approval. Preserve selection, clipboard, resize and live ConPTY behaviors.

The new package is not ready to import: `pubspec.yaml` and functional source will be added as part of the approved extraction checkpoint. No `main` merge or release is implied by repository creation.
