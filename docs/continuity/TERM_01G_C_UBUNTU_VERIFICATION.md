# TERM-01G-C — Ubuntu verification gate

Status (2026-11-21): **UBUNTU FLUTTER VIEWER ACCEPTANCE PASS** for the planned UI-mock scope. Operator confirmed Linux Debug build/GUI, two independent mock panes, mirror toggle in both directions, selection/copy, paste with confirmation and window resizing. **Real Linux PTY / Bash remains OUT OF SCOPE and unsupported.**

## Scope and explicit boundaries

- This repository is a **Flutter viewer**, not a Linux PTY/terminal engine.
  Flutter/xterm2 UI, registration over a supplied `TerminalHandler`,
  selection/clipboard/scrollback/resize UI and widget tests can run on Ubuntu.
- The current `remvibe_terminal` native engine implements Windows ConPTY
  only. **No Linux PTY process or true Bash shell is supported yet.**
- The example uses an explicit **UI MOCK** handler on Ubuntu. It displays
  demo bytes from two independent mock sources and a mirror of the first.
  It deliberately does not pretend that those are real terminals.
- If actual Bash/PTY execution on Ubuntu is required, it MUST be planned and
  accepted in the core `nusretm/remvibe_terminal` repository as a separate
  Linux PTY checkpoint. Never implement it inside the Flutter viewer.
- Do not modify Update Center, SCM or other frozen consumer projects.

## Host prerequisites

Ubuntu desktop with Flutter Linux desktop enabled and necessary standard
GTK/CMake/Clang dependencies. Typical setup on an Ubuntu development host:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
flutter config --enable-linux-desktop
flutter doctor -v
```

Use **one clone per Git repository** in the established project directory:
the Flutter viewer and terminal core may be separate sibling repositories,
but no `*_verify` or per-checkpoint worktrees.

## Execution

```bash
cd /path/to/remvibe_terminal_flutter
git status --short
# Preserve/inspect local changes before pulling.
bash tool/verify_ubuntu.sh
```

The script performs `flutter pub get`, `flutter analyze`, `flutter test`,
generates the Flutter Linux runner inside `example/`, analyzes and tests the
example, explicitly compiles `flutter build linux --debug`, and starts
`flutter run -d linux`. The final run needs a graphical Ubuntu desktop
session (`DISPLAY`/`WAYLAND_DISPLAY`); a headless CI host can prove build/tests
but **cannot** satisfy manual GUI acceptance. Observe the GUI manually.

## Acceptance criteria — UI-only

1. `flutter doctor` confirms Linux desktop toolchain.
2. Package dependency resolution and analyzer succeed.
3. Clipboard, resize, duplicate-viewer/unregister, state and UTF-8 Flutter
   tests pass.
4. Example Linux desktop build succeeds and launches.
5. UI clearly declares `UI MOCK` and `NO Linux shell`.
6. Two independent mock terminal panes render output simultaneously.
7. Switching to two viewers of one mock source displays duplicate output,
   independent selection and correct registration/disposal.
8. Linux mouse selection/copy and paste-confirmation behavior tested by
   operator; resizing each viewport does not crash the viewer.
9. No extra project folder/worktree, shell spawn or PTY native capability
   claim is introduced.

Record actual Ubuntu command output and operator feedback before claiming
pass. Window-close debugger messages are not automatically classified as
application crashes; evaluate observed behavior.

Real Ubuntu shell functionality is **not** part of this gate and requires
separate core-engine authorization.

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
