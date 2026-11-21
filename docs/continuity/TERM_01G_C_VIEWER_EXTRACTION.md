# TERM-01G-C — independent Flutter terminal viewer: proposed implementation

Status (2026-11-21): **TERM-01G-C scoped Windows functionality accepted: analyzer/tests, real dual PTYs, same-PTY mirror, detach/reattach and existing interactions PASS. Ubuntu Flutter Linux desktop verification PENDING. No merge/release.**

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

### Windows second operator run and test fixture repair (2026-11-21)

The first import warning was fixed; root `flutter analyze` now PASS ("No issues found"). Root `flutter test` reached 11 passes and one failure in `two independent viewers on one PTY unregister separately` at the `unregisterCalls == 1` assertion. The test inadvertently reparented the retained first viewer from `Row > Expanded` into a direct child, so Flutter correctly disposed both original widgets and created a new first widget. The expected single unregistration was incompatible with that fixture. Commit `1627ab816bd1497249cf30c8b233efccfeda02d7` preserves the first viewer's element-tree location when removing pane B and asserts the same registration token remains for pane A. **Only test source changed**, not the viewer/PTY implementation. A fresh Windows test run is pending; GUI and Ubuntu not reached. Operator's checkout retains Flutter-generated analyzer excludes and pubspec lock files; no extra worktree or destructive cleanup.

### Windows operator gate — third run (2026-11-21)

- Git fast-forward at the existing single local checkout preserved the Flutter-generated `analysis_options.yaml` changes and untracked `pubspec.lock` files.
- Root `flutter pub get`: PASS. Root `flutter analyze`: **PASS (No issues found)**. Root `flutter test`: **12/12 PASS**, including the corrected independent-viewer lifecycle test.
- `flutter create . --platforms=windows` generated platform runner in-place and also a default `example/test/widget_test.dart` referencing nonexistent `MyApp`. The example `flutter analyze` failed only on this Flutter template test (`creation_with_non_type` at line 16). Thus the script stopped **before Windows build/GUI**. No terminal-widget runtime failure is established.
- Committed `example/test/widget_test.dart` with a real UI-mock subscriber/replay/unregister test (commit `bc123eb00f4d636e7a7095b33030d1cba67b1a93`), replacing the generic template permanently for future fresh checkouts. The existing **untracked** local generated `example/test/widget_test.dart` must be checked and specifically removed **only if** it matches the default `MyApp` counter template before `git pull --ff-only` can create the tracked file. Do NOT reset/clean or delete any other local files.
- `tool/verify_windows.ps1` and `tool/verify_ubuntu.sh` now generate their platform runner only when absent and run `flutter test` inside `example/` as well. Same checkout only; no parallel worktree.
- Next: operator-controlled local template reconciliation, fast-forward pull, rerun the Windows verification script; collect example analyzer/tests, real Windows executable and GUI observations. Ubuntu gate remains **NOT RUN** until Windows acceptance.

### Windows operator gate — fourth run, real two-pane GUI (2026-11-21)

- Operator safely removed ONLY the generated, untracked Flutter `MyApp` counter-template file after a content check and fast-forwarded to `5c122032d495c6ab9268fd3661c89b84502ea230` in the existing `D:\Projects\remvibe_terminal_flutter` checkout. No parallel worktree; preserved other Flutter-generated files.
- Root `flutter pub get` PASS, root `flutter analyze` **No issues found**, root `flutter test` **12/12 PASS**.
- Example `flutter pub get` PASS, example `flutter analyze` **No issues found**, example `flutter test` **1/1 PASS**.
- Windows Debug `remvibe_terminal_flutter_example.exe` **built and launched** successfully. Operator supplied an actual GUI screenshot showing **two concurrent, independent PowerShell ConPTY terminals side by side**: left `PowerShell #1` executed `ls .\\build\\` and displayed the build directory; right `PowerShell #2` executed `ls` and displayed the example directory. This is observed GUI evidence for distinct concurrent local PTYs and terminal output rendering.
- The final Flutter CLI line was `Lost connection to device`. Operator previously explained that this message appears when the main Debug window is closed directly rather than exiting with `q`. No crash is established from this line alone.
- **Scope of PASS:** root and example static/test gates, actual Windows build/launch and two independent simultaneous terminals with real command execution.
- **Not yet operator-observed:** pressing `Show two viewers of first PTY` and confirming both panes receive a new output frame from ONE process; host `Detach first controller` / reattach with same shell PID and output retention; interactive clipboard/long selection/resize parity. Those final interactive checks are still required for full TERM-01G-C Windows acceptance.
- Ubuntu build/GUI testing remains **NOT RUN**, scheduled after the remaining Windows interactive checks. No merge, release, publication, service changes, or cleanup authorized.

### Windows final operator acceptance — fifth GUI observation (2026-11-21)

The operator supplied a Windows Debug screenshot in mirrored-view mode and
explicitly reported that **all tested interactions worked correctly**:

- First terminal shows `Write-Output "REMVIBE-MIRROR-OK"` and
  `REMVIBE-MIRROR-OK` in the left pane; the **same** command and output appear
  in the right pane titled `Same PTY • second viewer`. This validates two
  simultaneous displays observing a **single** terminal process.
- The screenshot shows `$PID` twice, both yielding **20624**, after the
  operator used detach/reattach; the application's status reads
  `Shell #1 controller reattached to same PTY`. This validates persistence
  of the shell process across control reattachment.
- Operator additionally confirms selection, copy/paste, resize, and other
  interacted functionality work. The screenshot shows the completed paste
  status `Pasted 5 characters`.
- The same bottom status also includes `incomplete output history`, a
  **visible replay/gap indicator**. Do not claim that historical output is
  universally complete; no functional failure was reported or established.
- Together with the earlier analyzer, **12/12 root tests**, **1/1 example
  test**, Windows build/launch and real concurrent independent PTYs, these
  observations close **TERM-01G-C scoped Windows functional acceptance PASS**.
  No further Windows gate is required before attempting Ubuntu Flutter UI
  verification. This is **not** a full cross-platform or release acceptance.
- Next target: Ubuntu root/example analyzer and tests, explicit Linux Debug
  build, two-pane **UI MOCK** verification and operator GUI observation.
  Current `remvibe_terminal` supports **Windows native ConPTY only**;
  Ubuntu test does **not** implement or claim a native Linux PTY.
- No main merge, package publication, cleanup, Update Center changes or
  SCM service operations are authorized. Continue one local checkout per
  repository.
