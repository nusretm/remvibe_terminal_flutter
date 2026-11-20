# TERM-01G-C — Ubuntu verification gate

Status: **REQUESTED BY OPERATOR 2026-11-21; NOT EXECUTED.** Run **after**
the extracted Flutter viewer passes Windows validation. This is a distinct
platform gate and must not be marked PASS based on source commits.

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
generates the Flutter Linux runner inside `example/`, analyzes the example,
and starts `flutter run -d linux`. Observe the GUI manually.

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
