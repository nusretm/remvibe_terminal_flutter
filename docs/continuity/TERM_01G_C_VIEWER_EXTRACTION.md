# TERM-01G-C — independent Flutter terminal viewer: proposed implementation

Status (2026-11-21): **Planning complete; explicit operator implementation authorization required.** No source migration has been performed.

## Why and owning repository

The independent `remvibe_terminal` core already exposes `TerminalHandler`, `TerminalHandlerLocal`, typed terminal state/output events, bounded replay and independently registered watchers. Extracting the known-working Flutter viewer to a separate package lets a local Console handler or consumer-provided future remote handler power exactly the same widget without importing Flutter into the core package.

Owner: `nusretm/remvibe_terminal_flutter` for **UI only**. Its public dependency is the core terminal contract. Existing `remvibe_terminal` example is the reference and must continue to work during migration.

## Existing source inventory (reference branch)

From `remvibe_terminal/example/lib/terminal_widget/`:

- `remvibe_terminal_widget.dart`: current xterm2 Flutter widget, input/output, paste dialog, Ctrl+C, status, dispose.
- `stable_scrollback_terminal_view.dart`: stable drag-selection, mouse/right-click and cursor interactions.
- `terminal_clipboard_paste.dart`: scalar-by-scalar Unicode clipboard sender, CRLF normalization.
- `terminal_resize_coordinator.dart`: latest-wins resize and output-aware settle heuristic.
- `terminal_session_api.dart`: old `TerminalSessionBinding` / provider contract that must not remain the new widget's public primary dependency.

`example/lib/local_terminal_session_provider.dart` and `example/lib/main.dart` are **demo application/session orchestration**. They remain example-owned; do not turn the reusable viewer into a session provider.

## Proposed public API and lifecycle

```dart
RemVibeTerminalWidget(
  handler: handler, // TerminalHandler, supplied by the host
)
```

- Each widget owns one independent xterm2 `Terminal` and handler registration token; callback registration is per pane. A viewer's `dispose` unregisters its own token, disposes its display and input/resize work, and must **not** implicitly terminate, detach another controller, or stop the PTY.
- Input/resize/interrupt delegate to `TerminalHandler`; observer-only handler must not be escalated to controller. Show capability/control errors from a read-only handler gracefully.
- Typed state callbacks drive exit/detach/status UI; raw bytes stream through an incremental UTF-8 decoder into xterm2. Respect `TerminalStreamEvent` sequence, replay and explicit gap; each pane maintains its own replay cursor.
- Parent application owns terminal creation, session list, explicit detach/control/terminate and which handler/pane is selected. No `TerminalSessionService` singleton is embedded in the viewer.
- Keep selection, context clipboard, paste confirmation, Unicode multiline paste and latest-wins resize behavior compatible with the existing operator-approved Windows example. Do not refactor the whole xterm2 interaction layer.

## Small checkpoints (after operator approval)

1. **C1 package scaffold:** Flutter `pubspec.yaml`, core dependency (initially the dedicated core feature ref for standalone checkout), public library export, existing helper files and tests. Keep package Flutter-only; no native sources.
2. **C2 handler widget:** lift the working widget, replace obsolete `TerminalSessionBinding` with the accepted `TerminalHandler`, wire registration/unregistration, typed state/stream events and explicit per-pane display ownership. No extra transport abstraction.
3. **C3 real demonstration:** standalone Flutter Windows example with two independent PowerShell PTYs in simultaneous panes, then two simultaneous viewers for one PTY (one may be read-only); verify independent selection and output and that disposing a viewer does not kill the PTY. The host demo, not the widget, owns local process creation.
4. **C4 parity/acceptance:** targeted Flutter tests plus actual Windows Debug operator checks for keyboard/Ctrl+C, Unicode multi-line paste with confirmation, right-click copy and stable drag selection, resize during running output, reattach, replay/gap, Ctrl+C and natural exit. Record outcomes in continuity; no merge/publish without explicit approval.

## Risks, verification and rollback

- **Risk: prematurely detaching the shared controller** when one pane closes. **Mitigation:** unregister-only widget disposal; explicit host-owned detach. Assert same PID and other viewer still receives output.
- **Risk: shared UI state across viewers.** **Mitigation:** separate per-widget xterm2 models/selection/replay tracking, tests for two viewers on one PTY.
- **Risk: output loss or UTF-8 corruption across byte frames.** **Mitigation:** incremental decoding, explicit sequence/gap reporting, tests with split UTF-8 and replay/live ordering.
- **Risk: incorrect UI write permission.** **Mitigation:** read-only viewer must remain read-only; only the existing controlling handler may call write/resize/interrupt.
- **Risk: existing UX regression.** **Mitigation:** preserve source helpers and current example until parity and operator GUI verification pass; compare behavior rather than redesign.

Rollback: leave `remvibe_terminal` and its operator-accepted Flutter example untouched; abandon the new package feature branch if verification fails. No rollback of an installed application, Update Center service or any release should be necessary.

## Exclusions and decision gate

No `TerminalHandlerRemote`, Networking, RPC, auth, device selection, Client/Server/Console protocols, persistent agent, SCM, installer, release or Linux/macOS implementation. `remvibe_terminal_flutter` must never import `remvibe_update_center`.

**Approval request:** Authorize implementing only C1-C4 above on `feature/term-01g-c-viewer-extraction`, with Windows-first tests and operator GUI acceptance. This document does NOT itself grant that authorization. Merge/release remains a separate decision.
