# Current target — remvibe_terminal_flutter

**TERM-01G-C — PLAN READY FOR OPERATOR IMPLEMENTATION APPROVAL; NO FUNCTIONAL CODE YET.**

- New repository: `nusretm/remvibe_terminal_flutter` (public; GitHub access verified).
- Feature branch: `feature/term-01g-c-viewer-extraction`.
- Reference core: `nusretm/remvibe_terminal`, feature branch `feature/term-01g-local-multi-handler`; operator verified TERM-01G-B Windows native/analyzer, 27/27 root Dart tests, real dual-PTY/two-watchers smoke, Flutter analyzer, 8/8 Flutter tests, and existing GUI multi-session create/detach/selection.
- `remvibe_terminal_flutter` currently contains **planning documents only**. There is no `pubspec.yaml`, exported widget, executable example, CI outcome or acceptance claim.
- Source-of-truth boundaries: `PROJECT_RESPONSIBILITIES.md`, `TERM_01G_C_VIEWER_EXTRACTION.md`, and `AGENTS.md`.
- Next gate: operator approval for the exact TERM-01G-C source migration scope. Then implement in small testable commits on the feature branch, without modifying frozen Update Center or its services.
- Windows acceptance after code: Flutter analyzer, helper/widget tests, real Windows GUI with two PTYs in simultaneous panes, two viewers of one PTY, independent subscription cancellation, copy/paste/selection/resize parity and no PTY termination when a viewer is disposed.
- No `main` merge, release, package publication, deployment or cleanup is authorized.

## Local directory rule (2026-11-21)

One local checkout per Git repository, normal feature branches, no temporary validation worktrees or per-task clones. For this project use `D:\Projects\remvibe_terminal_flutter`; the core remains `D:\Projects\remvibe_terminal`. Inspect any dirty status and protect existing files. The previously made `remvibe_terminal_term_01g_verify` checkout must not be used as a template; its cleanup is operator-controlled. See `AGENTS.md`.
