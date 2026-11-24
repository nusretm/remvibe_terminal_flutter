## Accepted infrastructure consolidation — CLOSED (2026-11-24)

**Operator acceptance, history-preserving merge and current-milestone cleanup COMPLETE.** No new feature target selected. Earlier acceptance scope and outstanding untested cases remain as documented below.

Merged baseline (before this documentation-only closure):
- remvibe_networking: `bca781e4963cda361aa2cf60add38f3ca6c8db9e` ([PR #67](https://github.com/nusretm/remvibe_networking/pull/67))
- remvibe_terminal_flutter: `b769ba728841adb55d3168a8e7c8af4bb1608c3c` ([PR #2](https://github.com/nusretm/remvibe_terminal_flutter/pull/2))
- remvibe_update_center_common: `8daee4b72ae2381bcc685cef38821142a36a70a1` ([PR #1](https://github.com/nusretm/remvibe_update_center_common/pull/1))
- remvibe_update_center_server: `28ab0672aa6e0b0725569f22a24aea1f659e015d` ([PR #2](https://github.com/nusretm/remvibe_update_center_server/pull/2))
- remvibe_update_center_client: `67eba52833e32c39bb2d08d20fe0ffe8c23eaa24` ([PR #2](https://github.com/nusretm/remvibe_update_center_client/pull/2))
- remvibe_update_center_console: `64ada090e98e3fe36fadfcedd0a3eadf2cde250e` ([PR #2](https://github.com/nusretm/remvibe_update_center_console/pull/2))

All six milestone remote branches were deleted with expected-SHA leases by the Windows operator and independently confirmed absent on GitHub. Windows local main synchronization and current-milestone branch cleanup completed for all six repositories. Common's five formatting-only edits are preserved in named stash `Common local formatting before consolidation`; Client and Console local generated files are preserved in their respective named stashes. Console local .gitignore and Windows runner files were preserved/restored without overwriting existing files; missing .metadata and analysis_options.yaml restored, flutter pub get succeeded with accepted Networking a7a7623, Terminal e415608, Terminal Flutter 005457a and Common 2732b79, plus resolved Flutter UI 3a0bde. Console retains local exclude rules for .gitignore and windows/; .metadata, analysis_options.yaml and pubspec.lock are untracked local files, not part of the merged source. No post-merge rebuild/runtime test claimed. Preserve stashes; no stash pop/drop, reset --hard or git clean.

Ubuntu Client operator reported `UBUNTU CLIENT CLEANUP PASS`: main synchronized to 67eba52833e32c39bb2d08d20fe0ffe8c23eaa24, current registration feature branch removed locally, dart pub get resolved Common 2732b79, clean main tracking origin/main. Local .dart_tool/ and pubspec.lock retained using .git/info/exclude. Older local feature/uc-client-linux-01-foreground-cli (d6c1590, upstream gone) intentionally untouched. Other historical Networking branches outside this milestone untouched.

Maintain the accepted working architecture. No additional CI, SCM/service deployment, identity deletion, database migration/reset, registry refactor, release or new module scope authorized by closure. Rejection runtime scenario remains untested; prior intermittent Ubuntu roster mismatch not reproduced after endpoint change, causal proof absent. Next target to be explicitly chosen by operator.

---

## UC-REGISTRATION-APPROVAL-01 / terminal control — accepted baseline (2026-11-24)

**Status: OPERATOR ACCEPTED; MERGE AND CLEANUP AUTHORIZED.** Tested source: `005457a`.

Viewer exposes generic leadingToolbarActions/trailingToolbarActions; host owns confirmation and takeover. No Networking or PTY dependency changes.

**Operator acceptance and closure authorization (2026-11-24):** MTN Windows Client and Ubuntu Client connect immediately after restart; restarting foreground Server reconnects Console and both Clients immediately; Ubuntu consistently appears Online in subsequent observations. LattePanda Windows release Console connects immediately, was enrolled from existing Console without a code, opens Ubuntu PTY and supports live shared observation. Server DB-loss recovery (original DB moved to backup-20261124-030929), automatic Client pending/approval, first Console short-code recovery, integrated Devices UI, shared hardware card and DisplayName persistence across Server restart were accepted. Existing identities retained. Earlier intermittent Ready/Offline mismatch did not recur after endpoint correction; causal proof is absent. Registry single-source-of-truth improvement deferred unless reproduced; no speculative refactor. Registration rejection not separately runtime-tested. No SCM, deployment, database reset, CI expansion, macOS or new feature work authorized here.

Terminal acceptance: operator opened MTN and Ubuntu terminals in primary Console, watched from LattePanda, confirmed takeover, observed former owner switch to viewer and takeover button enable immediately; cancellation left ownership unchanged, and closing/reopening tab left PTY running. No claim of separately tested Server-local PTY takeover, forced simultaneous takeover or PID measurement. Server analyze lib and Console flutter analyze lib clean with Common 2732b79 and viewer 005457a. Networking a7a7623 Windows FFI build passed (three dead-code warnings), existing endpoint checker Rust tests 2/2, Dart analyze lib clean; actual connection/reconnect acceptance as above. No new full suite or CI run claimed.

Operator explicitly approved continuity, merge and cleanup; use history-preserving merges so tested dependency SHAs remain reachable. Only current milestone branches are in cleanup scope; preserve unrelated refs, local changes and stashes. Next development target requires separate operator decision.

---

# Current target — remvibe_terminal_flutter

## Ubuntu main synchronization + local cleanup — ACCEPTED (2026-11-21)

**Operator Ubuntu execution:** at `/home/remvibe-admin/development/projects/remvibe_terminal_flutter`, original local `main` at `a4667f0400e0e2f2105c3d02afe10b78f83f8845` contained two modified analyzer configuration files, untracked `example/linux/` runner plus example metadata/README and root/example lockfiles. Operator first verified all changes were exactly expected and `fetch --prune` confirmed new remote main `6a9596249d7162431abd9eb2f22acc8c6b583b7e`. Existing stash was preserved. A full archive was created and verified at `/home/remvibe-admin/remvibe_terminal_ubuntu_backup_tSGAkI/flutter_local_files.tar.gz`, SHA-256 `2ea68fc8f8f853d0850fcc62e0dc2f06db23a86761de69259e43c0a8e15be0be`; separate `tracked_changes.patch`, before-status and stash listing were saved in that backup directory. A **new** Git stash `Ubuntu local files before terminal main consolidation` protected all current generated/config changes; original `TERM-02B Ubuntu generated files before real PTY` stash was verified intact. Fast-forward to `6a959624` passed. Both remaining feature branches were ancestry-checked then removed via `git branch -d`. Final local branch only `main`, clean status `## main`, and two preserved stashes; remote `origin/main` was SHA-verified. **Ubuntu Flutter local cleanup PASS.**

**Operational follow-up (non-destructive):** `## main` without `...origin/main` indicates Ubuntu Flutter main may not have upstream tracking configured. Set it to `origin/main` if needed. Generated `example/linux/` runner files are currently **in archive and stash, not guaranteed in the clean checkout**. Before running the real Bash GUI example again, restore verified runner files selectively or regenerate with Flutter, then rerun required checks; do not claim a post-cleanup GUI run. Keep both Ubuntu stashes and external archive, as well as Windows' separate saved stash. Do not delete the backup or `git stash drop`. No release, native/Flutter code change, Networking, Fleet, Update Center or SCM operation.

## Merge + branch cleanup — ACCEPTED (2026-11-21)

**Operator Windows acceptance:** at `D:\Projects\remvibe_terminal_flutter`, repo was fast-forwarded to `main` commit `a4667f0400e0e2f2105c3d02afe10b78f83f8845`; final `git status --short --branch` reported `## main...origin/main` with no file changes. Merge [PR #1](https://github.com/nusretm/remvibe_terminal_flutter/pull/1) preserved complete history. **Remote branch cleanup PASS:** operator-deleted both `feature/term-01g-c-viewer-extraction` and `feature/term-02b-flutter-linux-real-pty` with remote SHA lease; independently verified GitHub now lists **only `main`**. **Windows local cleanup PASS:** operator checked targets merged into main, deleted remaining `feature/term-01g-c-viewer-extraction` via `git branch -d`, and confirmed only local and remote `main` refs remain.

**Protected Windows work:** named stash `Windows Flutter generated files before main sync` retained, covering Windows-generated Flutter configuration/runner/lockfiles. Ubuntu local generated files, prior named stash and its original checkout were **not touched by Windows cleanup**; Ubuntu-specific local branch housekeeping is outside this confirmed result. Old Bash output gap warning remains accurately scoped in TERM-02B records; no code change or package release/publication. No worktree reset, `git clean`, stash pop/drop, installer, SCM, Update Center or Networking modifications.

## Main consolidation and cleanup handoff — 2026-11-21

**MERGED:** [PR #1](https://github.com/nusretm/remvibe_terminal_flutter/pull/1) merged to `main` as merge commit `aa3fab9842de2bbb8b01221ff1e50467dd638311`, preserving all 112 feature commits. Includes accepted Flutter terminal viewer on Windows, real Ubuntu Bash/PTTY example, GAP-01 exact history-gap range display and BASH-PROMPT-01 `exec /bin/bash -i` user prompt correction.

**Prerequisite:** native core [remvibe_terminal PR #1](https://github.com/nusretm/remvibe_terminal/pull/1) was already merged to core `main`; pinned core SHA `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b` is reachable from the merged core main. Keep exact pin; do not convert to an unverified moving branch.

**Evidence:** Ubuntu root Flutter analyzer + 15/15 widget tests and example analyzer + 1/1 test + Linux Debug build PASS at GAP-01 gate; later example-only Bash prompt fix analyzer + 1/1 test + Linux Debug build + actual operator two-pane GUI verification PASS. No root Flutter suite rerun after example-only prompt change; no new CI status reported. Both latest GUI panes showed the user's configured Bash prompt and `Watching`, without a visible history-gap warning. A previous history-gap cause remains unproven; bounded replay gap reporting intentionally remains.

**Historical cleanup handoff (now completed):** at merge time Ubuntu's generated files, tracked config changes, and old stash required protection, and remote feature-ref deletion required authenticated operator Git CLI. Windows remote cleanup and Ubuntu local cleanup later passed; the Ubuntu runner/config files are now preserved in an archive plus a new stash, with the old stash untouched. Avoid `git clean -fd`, `git reset --hard`, `git stash drop` or deleting an unreviewed worktree; no release/publication, Update Center, SCM, remote handler or Networking changes.

### Latest TERM-02B Ubuntu operator verification — Bash prompt PASS (2026-11-21)

**TERM-02B-BASH-PROMPT-01 ACCEPTED at operator-tested source `89e6808e609272d4d9961b5166dbe2279a33185b`:** after changing only Flutter example Linux startup from `--noprofile --norc -i` to `exec /bin/bash -i`, operator ran example `flutter analyze` (no issues), `flutter test` (**1/1 PASS**), and Linux Debug build (**PASS, exit code 0**), then opened `flutter run -d linux`. Screenshot shows two normal green Bash prompts `remvibe-admin@remvibe-ci-ubuntu:~$`, two independent commands/output, and `Watching` below both panels. Operator reports all GUI interactions rechecked and working, no manual `export PS1` needed.

**TERM-02B-GAP-01 automated gate remains PASS at `d1bb20b`:** root analyzer clean, **15/15 widget tests PASS**, example analyzer clean, **1/1 test PASS**, Linux Debug build PASS, exit 0. The newest screenshot shows **no visible gap warning** in either panel, including following user GUI interaction tests. This does not prove that the earlier warning's exact cause was identified, nor eliminate the legitimate bounded replay-gap detection. Latest source includes both fixes, but the root widget suite was not rerun specifically after the example-only prompt change.

**Scope and preservation:** previously accepted Ubuntu/Linux real PTY core technical gate and Windows ConPTY baseline stay intact. Existing generated Flutter runner/config files and the named stash remain preserved. No cleanup, main merge, release, publication, Networking, Update Center or SCM changes.

## TERM-02B active: real Ubuntu Bash terminal, not a mock (2026-11-21)

**TERM-02B Ubuntu real-Bash functional acceptance PASS (operator log and screenshot, 2026-11-21).** Existing Ubuntu checkout on `feature/term-02b-flutter-linux-real-pty` at source commit `8b745ab105b8c6733f8f532be6ea175ddb9ec3dc`, depending on core `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b`. Flutter root `flutter analyze` clean and **13/13 tests PASS**; example analyze clean and **1/1 test PASS**; Linux x64 Debug build **PASS** (verification exit **0**). Operator launched `flutter run -d linux`, screenshot confirms **REAL Linux Bash / PTY** and two `bash-5.3$` panes running distinct real filesystem commands; operator confirms all attempted interactions worked including controller reattach. This is an actual **real-shell GUI** acceptance, not historical UI mock.

**Follow-up observation, not silently discarded:** screenshot right footer says `Output sequence gap: incomplete history • incomplete output history`; left says `Watching`. No evidence yet to distinguish replay truncation/sequence warning from genuinely missing user-visible output. Keep as a scoped issue for focused review if reproducible; do not overstate complete output-history acceptance. No native change justified from screenshot alone.

**Boundaries:** older generated Flutter files saved in named Git stash; same existing checkout used. No main merge, release, cleanup, Flutter widget ownership expansion, Update Center/SCM/Networking/remote handler changes. See `TERM_02B_LINUX_REAL_GUI.md`.


**TERM-01G-C — ACCEPTED for scoped Flutter viewer behavior on Windows and Ubuntu. Windows real ConPTY and Ubuntu UI-mock build/GUI/interactions PASS. Real Ubuntu/Linux PTY is NOT implemented. Merge, release and cleanup require separate authorization.**

- New repository: `nusretm/remvibe_terminal_flutter` (public; GitHub access verified).
- Feature branch: `feature/term-01g-c-viewer-extraction`.
- Reference core: `nusretm/remvibe_terminal`, feature branch `feature/term-01g-local-multi-handler`; operator verified TERM-01G-B Windows native/analyzer, 27/27 root Dart tests, real dual-PTY/two-watchers smoke, Flutter analyzer, 8/8 Flutter tests, and existing GUI multi-session create/detach/selection.
- `remvibe_terminal_flutter` feature branch now has Flutter `pubspec.yaml`, exported `RemVibeTerminalWidget(handler:...)`, copied proven scrollback/clipboard/resize helpers, new typed handler registration/stream/state binding, 8 migrated helper tests and 4 new widget tests. These test sources ran successfully on Windows (12/12 root widget/helper tests, 1/1 example test); Ubuntu example tests and Linux Debug GUI gate passed (the Ubuntu root test count was not visible in the screenshot).
- A two-pane example exists: real ConPTY PowerShell pairs on Windows with toggle to duplicate the first PTY into two viewers, and an explicitly labeled UI-only mock on Ubuntu/Linux. No Linux PTY or real Ubuntu shell support is claimed.
- Source-of-truth boundaries: `PROJECT_RESPONSIBILITIES.md`, `TERM_01G_C_VIEWER_EXTRACTION.md`, and `AGENTS.md`.
- Operator agreed to proceed and requested Ubuntu compilation/testing after completing the widget. **First Windows gate (2026-11-21):** `flutter pub get` succeeded, including the pinned `remvibe_terminal` Git dependency at `bad58e`; `flutter analyze` STOPPED with a single `unnecessary_import` info in `test/remvibe_terminal_widget_test.dart:1` for `dart:async`. The unused import was removed in commit `03a3ea75dbd7d8364cefe9866912cd026afc6f10`, without changing widget/runtime behavior; Windows rerun is pending. Flutter also printed that it upgraded `analysis_options.yaml` to exclude generated paths; inspect local Git status before pulling, preserve local changes. Flutter tests, example Windows build and GUI were **not reached**. Ubuntu gate is still pending until Windows acceptance. No changes to frozen Update Center or its services.
- Windows acceptance: **PASS**. Root Flutter analyzer and 12/12 tests, example Flutter analyzer and 1/1 test, Debug EXE build/launch, independent PowerShell PTYs, duplicate viewers of one PTY, same PID before/after detach/reattach, and operator-confirmed copy/paste/selection/resize all passed (fourth/fifth operator GUI evidence). See latest gate below.
- Ubuntu acceptance (after Windows): Flutter Linux build, analyzer, tests, two-pane GUI **UI MOCK** demonstration and actual operator visual/clipboard/selection feedback. Results PENDING; separate Linux native PTY checkpoint needed for real shell support.
- No `main` merge, release, package publication, deployment or cleanup is authorized.

## Local directory rule (2026-11-21)

One local checkout per Git repository, normal feature branches, no temporary validation worktrees or per-task clones. For this project use `D:\Projects\remvibe_terminal_flutter`; the core remains `D:\Projects\remvibe_terminal`. Inspect any dirty status and protect existing files. The previously made `remvibe_terminal_term_01g_verify` checkout must not be used as a template; its cleanup is operator-controlled. See `AGENTS.md`.

### Windows operator gate — second run (2026-11-21)

- Operator continued in the existing single `D:\Projects\remvibe_terminal_flutter` checkout on `feature/term-01g-c-viewer-extraction` (pre-run HEAD `c43187b0b499fc54666a6a9b6a975ffbd2887f5c`). No verification worktree was created.
- `git status --short` showed only Flutter-generated `analysis_options.yaml` and `example/analysis_options.yaml` exclude-build additions, plus untracked `pubspec.lock` and `example/pubspec.lock`. `git pull --ff-only` completed without overwriting them. These files must remain protected; no reset/clean is allowed.
- `flutter pub get` root and example: PASS. Root `flutter analyze`: **No issues found, PASS**.
- Root `flutter test`: **11 passed / 1 failed**, stopping the script before Windows example build/GUI. Only failure: first widget test expected one unregister call after removing pane B but got two. The test had changed the retained pane A's parent element path from `Row > Expanded > Widget` to `Widget` directly, legitimately disposing both old viewer elements and creating a new pane A. This was a **test fixture error**, not evidence of a PTY subscription bug.
- Test corrected in commit `1627ab816bd1497249cf30c8b233efccfeda02d7`: preserve the original `Row > Expanded > Widget` path for pane A and verify the original registration token is retained when only pane B is removed.
- **Rerun required.** No claim yet of 12/12 test PASS, Windows example build, GUI or Ubuntu verification. Preserve local changes in the single checkout. Do not merge, release, deploy or clean up.

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

## Ubuntu operator evidence — first desktop run (2026-11-21)

- The operator supplied a real screenshot from Ubuntu's graphical desktop on `remvibe-ci-ubuntu`, with the Linux Flutter example running in a window beside the successful verification terminal.
- Visible terminal results: example `flutter analyze` **No issues found**; example `flutter test` **1/1 PASS**; explicit `flutter build linux --debug` completed and emitted `build/linux/x64/debug/bundle/remvibe_terminal_flutter_example`; `flutter run -d linux` built/launched a real desktop window, printed the VM Service address, and synced to the device.
- The successful arrival at the example Linux compile/run means the preceding root `flutter pub get`, analyzer and tests in the stop-on-error script did not stop it. The screenshot does **not** expose the earlier root test count; do not fabricate the exact number from the cropped scrollback.
- The screenshot clearly shows `UI mock — no Linux shell` and `UBUNTU UI-ONLY TEST: mock source; Linux native PTY not supported`. Left pane `Mock #1` renders scrollback lines 93–110 and live mock frames 1–12; right pane `Mock #2` renders its own live mock frames 1–12. **Ubuntu UI-only two-independent-pane render and Linux Debug build/launch PASS.**
- Non-fatal `libEGL warning: DRI3 error: Could not get DRI3 device` messages occurred, but Flutter opened and rendered the actual UI; no crash is established by the warnings.
- The screenshot remains in **two separate mock sources mode** (button offers `Show two viewers of first PTY`). There is no operator observation yet of switching into two viewers of one mock source on Ubuntu, or of Linux selection/copy, paste confirmation and resize interactions. Those interactive checks remain **PENDING** for full scoped Ubuntu widget acceptance.
- The Linux test is **not** native Ubuntu terminal/shell support: the core remains Windows ConPTY-only. No modifications to the core, Update Center, SCM services, main branch, release, deployment or cleanup are authorized. Continue with one existing checkout per repository.

## Ubuntu operator follow-up — reversible mirror interaction (2026-11-21)

- Operator manually clicked `Show two viewers of first PTY` in the running Ubuntu Flutter example. **First click PASS:** the right pane switched from independent mock #2 into a mirror of the first mock source.
- **Second click PASS:** the right pane returned to the independent second mock terminal source.
- This is operator-confirmed **reversible UI mock source switching / multiple viewers of one event source**. The Ubuntu Linux Debug build and dual-pane launch were already verified in the previous run.
- The operator did not separately report Ubuntu-specific drag selection/copy, paste confirmation or resize behavior in this follow-up. These remain **unverified on Ubuntu**, rather than silently accepted.
- No real Linux shell or PTY is involved; no native Linux implementation is claimed. No merge, release, publication, destructive checkout cleanup or changes to `remvibe_terminal`, Update Center or SCM are authorized.

## TERM-01G-C Ubuntu final operator acceptance — 2026-11-21

Following the operator-confirmed Ubuntu build, running Flutter desktop window,
two independent mock terminal displays and reversible same-source viewer toggle,
the operator explicitly confirmed **window resizing, text copy, paste and the
paste-confirmation dialog all work correctly**. The preceding question also
covered text selection; the operator replied affirmatively. This closes the
remaining planned Ubuntu Flutter viewer interaction checks.

**Acceptance boundary:** Windows real ConPTY terminal/viewer functionality
and Ubuntu **Flutter UI-mock viewer** functionality are now accepted for
TERM-01G-C. Ubuntu used a simulated TerminalHandler only; **real Linux/Bash
PTY support has neither been implemented nor tested**. An earlier visible
`libEGL / DRI3` warning did not prevent GUI rendering. The earlier
`incomplete output history` indicator in the Windows screenshot is an
explicit replay/gap warning, not proof of complete output history. The Ubuntu
root test suite completed far enough to reach the Linux example build in the
stop-on-error script, but the screenshot did not expose an exact root test
count; do not invent one.

The earlier dated sections documenting pending checks are **chronological
history**, superseded by this final operator acceptance. The approved scope
does not permit automatic PR merge, package publication, deployment,
worktree cleanup or any changes to `remvibe_terminal`, Update Center,
Networking, Windows SCM services or native Linux PTY support. One local
checkout per repository remains mandatory.
