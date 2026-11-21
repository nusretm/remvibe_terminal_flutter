# TERM-02B — Real Linux Bash/PTTY Flutter integration

Status (2026-11-21): **TERM-02A Ubuntu real Linux PTY core technical gate PASS (35/35 Dart tests and real dual-Bash multi-handler smoke, exit 0, exact source `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b`).** TERM-02B reusable Flutter viewer and example source are ready; **Ubuntu Flutter analyzer/tests/Linux Debug build and real-shell GUI operator acceptance PENDING**. No merge/release.

## Operator goal

The reason to build independent RemVibe Terminal packages is to support **real operating-system terminals on Linux as well as Windows**, not to stop with UI mock verification. Operator explicitly requested native Linux PTY development/testing after completing the TERM-01G-C viewer scope.

- `remvibe_terminal` core feature: `feature/term-02a-linux-pty`.
- Core dependency pinned to **`e415608878daaa16b0d0ba1eaab3a2c272f3fe4b`** in both this package and example. Do NOT pin to the previously accepted `bad58e` Windows-only commit when verifying real Linux.
- Flutter integration feature: `feature/term-02b-flutter-linux-real-pty`, based on the accepted `feature/term-01g-c-viewer-extraction` head. The accepted Windows and UI-mock feature branches remain unchanged.

## Implementation boundaries

- Only the **core** repository owns openpty/supervised child, Linux process groups, native
  PTY I/O, resize, Ctrl+C, exit/wait, Native Assets compilation and process
  lifecycle. See `remvibe_terminal/docs/continuity/TERM_02A_LINUX_PTY.md`.
- The Flutter viewer still consumes only `TerminalHandler`. No PTY process,
  socket, Fleet or remote handler code is introduced into the viewer.
- The example now detects Linux and calls `RemVibeTerminal.currentPlatform()`
  to open two real interactive `exec /bin/bash --noprofile --norc -i`
  shells, each with its own process and controller; Windows continues using
  its existing PowerShell/ConPTY path.
- Clicking `Show two viewers of first PTY` mirrors one real Bash process.
  Clicking again restores independent Bash #2. Detach/reattach preserves the
  actual child PID; the UI never terminates a PTY when only a viewer closes.
- `RemVibeTerminalWidget` gained optional `windowsPtyMode` (default
  `true`, preserving accepted Windows rendering). Linux's local example
  passes `false`. The setting is supplied by the **host application**
  based on the terminal's origin, not automatically inferred from whether
  the Flutter viewer happens to run on Windows/Linux. This supports future
  remote viewers without coupling UI to a local process OS.
- A fake `MockTerminalHandler` remains as a non-native-platform fallback
  and a test fixture only. Ubuntu/Linux **does not use the mock** on this
  feature branch.


## TERM-02A verified prerequisite (2026-11-21)

Operator's existing Ubuntu checkout of `remvibe_terminal` on `feature/term-02a-linux-pty` at `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b` completed `bash tool/verify_linux.sh` with **EXIT CODE 0**. Root analyzer had no issues, all **35/35 Dart tests passed**, and the live Ubuntu smoke passed two independently controlled real Bash PTYs, two viewers of the same PTY, process PID, resize, handler unregister, detach/reattach/replay, Ctrl+C and natural exit code 7. Core acceptance is therefore no longer a blocker. Flutter/UI acceptance below remains to be executed and reported by the operator.

## Required Ubuntu verification (TERM-02B still pending)

Use the **existing single repository checkouts** under the operator's
`~/development/projects/`. Clone the core once if absent. No temporary
`*_verify` checkout/worktree and no destructive cleanup.

1. In the core repo, checkout `feature/term-02a-linux-pty`, then execute
   `dart pub get`, `dart analyze --fatal-infos`, `dart test` and
   `dart run tool/term_02a_linux_live_smoke.dart`.
2. Confirm native live smoke shows independent real PIDs, real Bash output,
   two observers of one PTY, resize (`stty size`), Ctrl+C, detach/reattach,
   replay and natural exit code. No simulated source counts as a substitute.
3. In the existing Flutter repo, checkout
   `feature/term-02b-flutter-linux-real-pty`; ensure dependency resolves to
   core commit `e4156088...`.
4. Run `bash tool/verify_ubuntu.sh`, which performs Flutter
   analyze/tests, real Linux Debug build and `flutter run -d linux`.
5. Real GUI: **two Bash prompts**, one per pane. Type distinct commands.
   Verify `echo \"RVTERM_REAL_1\"` on left and `echo \"RVTERM_REAL_2\"`
   on right, with only the corresponding terminal reacting.
6. Click mirror, send `echo RVTERM_MIRROR` in left, see the same line in
   both; switch back to two independent PTYs.
7. Run `echo $$` before/after first controller detach+reattach; PID
   must match. Confirm PTY remains running while detached.
8. Resize and run `stty size`; test Ctrl+C after `sleep 20`, clipboard
   copy/paste confirmation and text selection.
9. Record actual logs/screenshot and operator feedback. Ubuntu native PTY
   and Flutter GUI acceptance **must not** be declared PASS before results.
10. Windows ConPTY regression and existing UI behavior remain protected; no
    feature branch merging, publication or cleanup without operator approval.

## Scope exclusions

No remote terminal adapter, Networking, Client/Server/Console routing,
Update Center, installer, Windows SCM, daemon persistence, new OS outside
Windows/Linux or unrelated security mechanics. Any such work needs a
separate accepted checkpoint.
