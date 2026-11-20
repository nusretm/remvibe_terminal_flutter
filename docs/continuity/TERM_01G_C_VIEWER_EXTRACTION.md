# TERM-01G-C — independent Flutter terminal viewer: proposed implementation

Status (2026-11-21): **C1–C3 Flutter source on dedicated feature branch; uncompiled/unverified. Windows acceptance first; Ubuntu Flutter UI verification afterward. No merge/release.**

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

**Approval record:** Operator agreed to proceed with TERM-01G-C and expressly requested Ubuntu compilation/testing after widget completion. Source was implemented only within this UI-only scope; test source presence is NOT test PASS or product acceptance. Ubuntu UI testing does not imply permission to implement Linux native PTYs. Merge/release remains a separate decision. Merge/release remains a separate decision.

## Implementation evidence — C1–C3 source (2026-11-21)

- Flutter-only root library and package metadata created; core git dependency pinned to `bad58e1244bfced08fe18c485df71f1acbd8cd7b`, an operator-accepted TERM-01G-B feature commit.
- Extracted existing working `stable_scrollback_terminal_view.dart`, `terminal_clipboard_paste.dart`, and `terminal_resize_coordinator.dart` with minimal behavior changes.
- `lib/src/remvibe_terminal_widget.dart` now consumes a required `TerminalHandler`, optionally displays a label and UI-only `readOnly` state, registers typed state/output callbacks, maintains incremental UTF-8 and per-pane gap/sequence, and unregisters itself on disposal. It never detaches/terminates the PTY. Existing selection, clipboard confirmation, sequential paste and resize code was preserved.
- Ported original clipboard/resize helper tests (8 total) and added four widget test sources for two watchers, independent disposal, read-only control, gap/exit and split UTF-8.
- New `example/lib/main.dart` displays two simultaneous real Windows PowerShell ConPTY terminals and a toggle for two viewers of the first; explicit host-initiated detach/reattach included. Ubuntu/Linux uses `example/lib/mock_terminal_handler.dart` labeled **UI-only mock**, not a real Linux shell.
- `tool/verify_windows.ps1` and `tool/verify_ubuntu.sh` added to run in the **same repository checkout**, without sibling `*_verify` folders. Ubuntu checklist: `TERM_01G_C_UBUNTU_VERIFICATION.md`.

**Windows operator evidence — first attempt (2026-11-21):** The operator cloned the new repository into the single authorized `D:\Projects\remvibe_terminal_flutter` directory and switched to `feature/term-01g-c-viewer-extraction`. Running `tool/verify_windows.ps1` resolved all package/example dependencies, including core Git ref `bad58e`. Root `flutter analyze` stopped on exactly one `unnecessary_import` info: redundant `dart:async` in `test/remvibe_terminal_widget_test.dart`. The redundant import was removed in commit `03a3ea75dbd7d8364cefe9866912cd026afc6f10`. A Windows rerun has NOT been supplied yet; do not report analyze/test/GUI PASS. The launcher had not reached Flutter tests, Windows example build/run, or Ubuntu testing. Flutter printed automated `analysis_options.yaml` upgrades; protect local changes and do not create a verification worktree. Flutter/Dart are unavailable in the authoring environment, so the operator must supply actual Windows and Ubuntu outcomes. The original `remvibe_terminal` implementation and frozen Update Center remain unchanged.
