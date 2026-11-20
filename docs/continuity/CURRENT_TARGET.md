# Current target — remvibe_terminal_flutter

**TERM-01G-C — Flutter package C1–C3 SOURCE IMPLEMENTED; Windows/Ubuntu execution and operator acceptance PENDING.**

- New repository: `nusretm/remvibe_terminal_flutter` (public; GitHub access verified).
- Feature branch: `feature/term-01g-c-viewer-extraction`.
- Reference core: `nusretm/remvibe_terminal`, feature branch `feature/term-01g-local-multi-handler`; operator verified TERM-01G-B Windows native/analyzer, 27/27 root Dart tests, real dual-PTY/two-watchers smoke, Flutter analyzer, 8/8 Flutter tests, and existing GUI multi-session create/detach/selection.
- `remvibe_terminal_flutter` feature branch now has Flutter `pubspec.yaml`, exported `RemVibeTerminalWidget(handler:...)`, copied proven scrollback/clipboard/resize helpers, new typed handler registration/stream/state binding, 8 migrated helper tests and 4 new widget tests. These test sources have **not** been executed.
- A two-pane example exists: real ConPTY PowerShell pairs on Windows with toggle to duplicate the first PTY into two viewers, and an explicitly labeled UI-only mock on Ubuntu/Linux. No Linux PTY or real Ubuntu shell support is claimed.
- Source-of-truth boundaries: `PROJECT_RESPONSIBILITIES.md`, `TERM_01G_C_VIEWER_EXTRACTION.md`, and `AGENTS.md`.
- Operator agreed to proceed and requested Ubuntu compilation/testing after completing the widget. **First Windows gate (2026-11-21):** `flutter pub get` succeeded, including the pinned `remvibe_terminal` Git dependency at `bad58e`; `flutter analyze` STOPPED with a single `unnecessary_import` info in `test/remvibe_terminal_widget_test.dart:1` for `dart:async`. The unused import was removed in commit `03a3ea75dbd7d8364cefe9866912cd026afc6f10`, without changing widget/runtime behavior; Windows rerun is pending. Flutter also printed that it upgraded `analysis_options.yaml` to exclude generated paths; inspect local Git status before pulling, preserve local changes. Flutter tests, example Windows build and GUI were **not reached**. Ubuntu gate is still pending until Windows acceptance. No changes to frozen Update Center or its services.
- Windows acceptance: Flutter analyzer, helper/widget tests, real Windows GUI with two PTYs in simultaneous panes, two viewers of one PTY, independent subscription cancellation, copy/paste/selection/resize parity and no PTY termination when a viewer is disposed. Results PENDING.
- Ubuntu acceptance (after Windows): Flutter Linux build, analyzer, tests, two-pane GUI **UI MOCK** demonstration and actual operator visual/clipboard/selection feedback. Results PENDING; separate Linux native PTY checkpoint needed for real shell support.
- No `main` merge, release, package publication, deployment or cleanup is authorized.

## Local directory rule (2026-11-21)

One local checkout per Git repository, normal feature branches, no temporary validation worktrees or per-task clones. For this project use `D:\Projects\remvibe_terminal_flutter`; the core remains `D:\Projects\remvibe_terminal`. Inspect any dirty status and protect existing files. The previously made `remvibe_terminal_term_01g_verify` checkout must not be used as a template; its cleanup is operator-controlled. See `AGENTS.md`.
