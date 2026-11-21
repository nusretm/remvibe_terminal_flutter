# TERM-02B — Real Linux Bash/PTTY Flutter integration

Status (2026-11-21): **TERM-02A native Linux PTY technical PASS; TERM-02B real Bash Ubuntu GUI functional PASS.** TERM-02B-GAP-01 warning-range change passed root analyzer and **15/15 widget tests**, example analyzer and **1/1 test**, Linux Debug build (**exit 0 at `d1bb20b`**). TERM-02B-BASH-PROMPT-01 example-only `exec /bin/bash -i` verified on Ubuntu at `89e6808e609272d4d9961b5166dbe2279a33185b`: example analyzer clean, **1/1 test PASS**, Linux Debug build PASS, launch and visual/interactive operator check PASS. Screenshot shows both configured Bash prompts, both viewers `Watching`, and no visible gap warning. The historical gap cause remains unproven; one clean run does not imply gaps are impossible. No merge/release/cleanup.

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
  to open two real interactive `exec /bin/bash -i`
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

## Ubuntu operator attempt — TERM-02B branch was not reached (2026-11-21)

- Operator invoked the preflight `verify_term02b_build` from its existing Ubuntu checkout `~/development/projects/remvibe_terminal_flutter`. It exited **before Git fetch/switch, analyzer, tests or build** because the checkout was dirty:
  `M analysis_options.yaml`, `M example/analysis_options.yaml`, and untracked `example/.metadata`, `example/README.md`, `example/linux/`, `example/pubspec.lock`, `pubspec.lock`.
- Operator then invoked `flutter run -d linux` directly from `example`. Flutter built `remvibe_terminal_flutter_example`, but the operator reported seeing **UI-mock terminals, not real Bash**. This launch **does not verify the TERM-02B branch**, since preflight never switched the checkout. The `Lost connection to device` line by itself does not identify a crash; it can appear on window close.
- The TERM-02B feature's remote `example/lib/main.dart` explicitly sets `_supportsNative = Platform.isWindows || Platform.isLinux`, starts two native Bash terminals when on Linux, and labels them `Bash #1` and `Bash #2` with `REAL Linux Bash / PTY`. The mock fallback is for other platforms only. Local branch/HEAD and source must be verified before attributing the mock screen to the new native implementation.
- **Preserve all modified/untracked generated runner files.** Do not delete, clean, overwrite, create an additional checkout/worktree or automatically merge. First inspect branch and changes; if switching is blocked, preserve files in a named, reversible Git stash limited to the operator-listed paths, then use the SAME checkout on TERM-02B. Do not claim a Flutter analyzer/build/real-shell GUI PASS yet.

## TERM-02B Ubuntu real-shell GUI — operator functional acceptance (2026-11-21)

**Actual verification, not a mock:** On the existing `~/development/projects/remvibe_terminal_flutter` checkout the operator first preserved old generated files with a named Git stash, then switched to `feature/term-02b-flutter-linux-real-pty` at `8b745ab105b8c6733f8f532be6ea175ddb9ec3dc`. The root and example `pubspec.yaml` both pin Ubuntu-verified native core `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b`.

**Automated build and tests (operator log):**
- Root `flutter pub get` PASS; `flutter analyze`: **no issues found**.
- Root `flutter test`: **13/13 PASS** including the new Linux PTY viewport test; other widget behaviors remain covered.
- `flutter create . --platforms=linux` generated the Linux runner in the **same checkout**, not a new worktree.
- Example `flutter pub get` PASS; example `flutter analyze`: **no issues found**; example `flutter test`: **1/1 PASS** (fixture uses UI mock, so this test by itself does not prove native Bash).
- `flutter build linux --debug`: **PASS**, produced `build/linux/x64/debug/bundle/remvibe_terminal_flutter_example`; surrounding verification command **EXIT CODE 0**.
- `flutter run -d linux`: launched and rendered actual dual-terminal GUI; GPU/DRI3 warning was nonblocking. `Lost connection to device` appeared after the runtime session; this alone does not establish a crash.

**Operator visual/interactive acceptance:** Submitted screenshot visibly shows the `REAL Linux Bash / PTY` chip, separate `Bash #1` / `Bash #2` panes with `bash-5.3$` prompts, and executed real filesystem commands (`ls -la` and `ls -la build/linux/x64/debug/`) with corresponding directory listings. The top message says `Shell #1 controller reattached to same PTY`. Operator explicitly said **all operations were tried and worked properly**, confirming the real-shell demo interactions (including mirror and controller detach/reattach) at the tested functional scope. This is the **TERM-02B Ubuntu GUI functional acceptance**, not a Git main merge, package publication or general platform release.

**Nonblocking observation to track:** The screenshot's right viewer footer displays `Output sequence gap: incomplete history • incomplete output history`; left footer says `Watching`. In the current widget implementation that warning is raised on a gap event or skipped sequence number and can persist as an output-history indicator. There is insufficient evidence to decide whether the warning represents missing bytes during a re-subscription/replay or only an expected historical gap; do not dismiss it as cosmetic or claim complete replay history. Operator reports that visible interactions worked. Record the warning for focused investigation if it recurs, without modifying the accepted native PTY, Update Center or SCM as part of this checkpoint.

**Repository discipline:** The operator's initial generated/modified Flutter files are saved in a named reversible Git stash; new generated files produced by Flutter are preserved. No automatic stash drop, cleanup, merge, release, new checkout, remote adapter, Networking, Update Center or SCM changes are authorized. The accepted prior Windows ConPTY and historical Ubuntu mock branch remain separate.

## TERM-02B-GAP-01 — output-history warning diagnosis (2026-11-21)

**Trigger:** After the scoped successful real Ubuntu Bash GUI acceptance the operator agreed to a focused follow-up on the screenshot's right-panel footer `Output sequence gap: incomplete history • incomplete output history`. This is a **separate, pending diagnostic**, not a reversal of TERM-02A native or TERM-02B tested functional acceptance.

**Source findings:**
- The core's `TerminalSessionService` retains at most the configured replay bytes (example: **64 KiB**). `TerminalSession.registerHandler(afterSequence: 0)` replays the retained frames to each newly created viewer. The core emits a genuine inclusive `TerminalStreamEvent.gap(fromSequence, toSequence)` when earlier frames are unavailable, or when its bounded per-viewer pending queue drops frames. Core `test/terminal_multi_handler_test.dart` already covers both truncated replay and a slow viewer's queue gap.
- The Flutter widget creates a fresh independent subscription on each viewer mount. Restoring the second pane after the mirror operation is a new subscription, so an already truncated replay can legitimately produce a warning despite normal current Bash input/output.
- The original footer repeated `incomplete history` and `incomplete output history` and **did not expose the missing range**, making the cause impossible to inspect from the screenshot. We cannot tell from that image whether the event was historical replay truncation or actual missed live frames. Do NOT erase/suppress gap events or claim they are cosmetic.

**Narrow, Flutter-only source change:** `lib/src/remvibe_terminal_widget.dart` now retains the **latest exact missing range** as `from–to` from the core event (or detects a skipped sequence) and displays `<status> • incomplete output history (last gap X–Y)`. It removes duplicated wording but keeps the warning visible across later state updates. Added tests for ordered gap-free output and implicit skipped sequences, and extended the existing explicit-gap test to verify the range; existing test fixtures remain fake to test UI semantics rather than to assert real PTY success. No core C++, Dart FFI, session service, handler contract, event schema or Windows ConPTY changes.

**Automated acceptance gate PASS for TERM-02B-GAP-01 at `d1bb20b99d5f4bfb94494d50fd22caff5a82c0d4`:** In the existing Ubuntu checkout, operator's root Flutter analyzer was clean, **15/15 widget tests PASS**, example Flutter analyzer clean, **1/1 test PASS**, Linux Debug build PASS, and verification command **exit code 0**. **Live GUI repetition/identification of the gap range is still pending**; the UI warning cannot be dismissed without evidence. A separate example-only Bash prompt fix was committed afterward and must be built/run separately. Preserve locally generated files and named stash; no merge/release/cleanup/Update Center/SCM actions.

## TERM-02B-BASH-PROMPT-01 — Use the user's Bash prompt (2026-11-21)

**Operator observation:** Real Linux PTY and GUI worked, but interactive Bash displayed the generic `bash-5.3$` prompt. The operator had to manually run `export PS1='\u@\h:\w\$ '` in each shell to get the expected `user@host:working-directory$` appearance.

**Cause:** The Flutter example explicitly launched `exec /bin/bash --noprofile --norc -i`. In particular, `--norc` disables the user's `~/.bashrc`, which normally configures Ubuntu's interactive prompt and aliases.

**Narrow example-only change:** Launch `exec /bin/bash -i` for Linux. This is still a real non-login interactive Bash in the existing native PTY; it loads `~/.bashrc` so the user's own `PS1`, colors and aliases are respected. Do not impose a hard-coded `PS1` over a user's configuration. The Windows PowerShell command is unchanged; native PTY, FFI, widget/handler contracts and service are unchanged. The independent TERM-02A native smoke deliberately uses `--noprofile --norc` for reproducible tests; **do not change that smoke's setup to fix the Flutter demo prompt**.

**Ubuntu operator prompt verification PASS (2026-11-21, source `89e6808e609272d4d9961b5166dbe2279a33185b`):** `verify_prompt01` fast-forwarded from `d1bb20b` to this commit, checked that `example/lib/main.dart` uses `exec /bin/bash -i`, and completed example `flutter pub get`, `flutter analyze` (no issues), `flutter test` (**1/1 PASS**) and `flutter build linux --debug` (PASS) with **EXIT CODE 0**. `flutter run -d linux` opened real Bash panes. The screenshot confirms both shells use the configured green `remvibe-admin@remvibe-ci-ubuntu:~$` prompt without manually setting PS1, each with real command output. The operator reported repeating all GUI interactions successfully. This is an example-only prompt-fix acceptance, not a change to core's reproducible smoke. The widget GAP-01 automated **15/15 PASS** was at the earlier `d1bb20b` commit; this prompt-only verification did not rerun the root tests.

## Latest GUI observation — no visible gap in retested Ubuntu panes (2026-11-21)

The second operator screenshot shows **two real Bash panes** with normal configured prompts and status **`Watching`** beneath both. Unlike the earlier screenshot, **no incomplete-history warning is visible** in this session. The operator reported all repeated interactions working. This does not establish that bounded replay never drops earlier frames or that the historical gap's precise origin has been identified; the gap-range warning remains active for missing frames.

Generated Flutter files and the prior named stash remain preserved. No cleanup, new checkout, merge, release, publication, Networking, Update Center, SCM or native PTY changes.
