# TERM-01G-C — Ubuntu verification gate

Status: **UBUNTU TECHNICAL BUILD + INITIAL TWO-PANE GUI PASS; FINAL INTERACTION ACCEPTANCE PENDING.** Operator supplied a genuine Ubuntu desktop screenshot (2026-11-21) showing successful Linux Debug build, live Flutter window and two independent UI-mock panes. Same-source mirror, clipboard/selection and resize checks are still pending; this does NOT establish native Linux PTY support.

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
