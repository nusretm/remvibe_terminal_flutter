# remvibe_terminal_flutter — Working rules

**TERM-02B Linux real-Bash Flutter example ACTIVE (2026-11-21):** based on accepted viewer branch, with core `remvibe_terminal` dependency pinned at **`e415608878daaa16b0d0ba1eaab3a2c272f3fe4b`**, the exact Ubuntu-verified native Linux PTY source. Core TERM-02A Dart analyzer clean, **35/35 root tests PASS**, real two-Bash multi-handler smoke PASS. **Flutter TERM-02B Ubuntu analyzer/tests/Debug Linux build and live real-shell GUI not yet tested/accepted.** Scope stays viewer/example only; no PTY implementation in Flutter, no Networking/remote adapter/Update Center, no automatic merge/release/cleanup. See `docs/continuity/TERM_02B_LINUX_REAL_GUI.md`.


**Current state (2026-11-21): TERM-01G-C WINDOWS AND UBUNTU FLUTTER VIEWER SCOPE ACCEPTED.** Windows: root 12/12 and example 1/1 tests, real ConPTY two-terminal/mirrored-view/same-PID reattach, clipboard/selection/resize PASS. Ubuntu: Linux Debug build, example analyzer/test, two UI-mock panes, reversible shared-viewer toggle, selection/copy, paste/confirmation and resize PASS (operator verified). Native Linux PTY or real Bash is **NOT implemented**. No main merge, release, deployment or cleanup.

Read `docs/continuity/PROJECT_RESPONSIBILITIES.md`, `docs/continuity/CURRENT_TARGET.md`, and `docs/continuity/TERM_01G_C_VIEWER_EXTRACTION.md` before any implementation.

- Product First; Functionality First; Windows First. Preserve the already Windows-accepted terminal user experience.
- This repository owns only reusable Flutter terminal UI, not a terminal engine. Keep its public dependency on the neutral `remvibe_terminal` `TerminalHandler` contract and Flutter/xterm2.
- The live reference implementation is in `nusretm/remvibe_terminal` at `feature/term-01g-local-multi-handler`, under `example/lib/terminal_widget/`. Extract existing working behaviors; do not rewrite them unnecessarily.
- Reusable public target: `RemVibeTerminalWidget(handler: ...)`. Each widget owns its own xterm2 display, subscriptions, clipboard/selection/focus and resize coordinator. It does NOT own or destroy a PTY.
- View registration must not imply control. A read-only viewer must not receive implicit write/resize/interrupt permission; unregistration must not terminate the terminal or affect other viewers.
- Preserve pinned stable scrollback selection, right-click copy/scroll, confirmation before paste, Unicode/newline sequential paste, latest-wins resize, keyboard, Ctrl+C handling, ANSI/VT rendering, exit and error display.
- Terminal stream source, sequence/replay/gap and activity state remain core-owned. Never infer command completion from output/prompt/silence.
- Do not implement `TerminalHandlerRemote`, RemVibe Networking, Server/Client/Console routing, identity/auth, SCM, native PTY/DLLs, installers, update engines, cross-device delivery or notifications here.
- The `remvibe_update_center` repository and active Windows services are frozen and MUST NOT be modified. Do not modify or cleanup original `remvibe_terminal` worktrees without explicit permission.
- Operator agreed to continue TERM-01G-C and requested a follow-on Ubuntu check. The approved UI-only work is on the feature branch; Windows analyzer/tests, two-terminal/two-viewer Debug demonstration and explicit operator acceptance are required. Then perform Ubuntu Flutter analyzer/tests and Linux UI-mock demonstration; neither constitutes Linux PTY support. No new responsibility may be added without separate approval.
- No automatic PR merge, release, package publication, deployment or cleanup.

## Local checkout policy — mandatory (2026-11-21)

- **One local checkout per repository.** Use `D:\Projects\remvibe_terminal_flutter` for this repo, and the existing `D:\Projects\remvibe_terminal` for its core dependency. Do NOT create `*_verify`, task-specific clones, parallel Git worktrees, or per-branch project folders without explicit operator approval.
- Work with ordinary branches in those directories. If Git status is dirty, inspect and preserve the existing edits/generated Flutter runner files; do not use an isolated checkout as an automatic workaround. Keep temporary build/test files under the ordinary ignored build paths.
- The earlier core `remvibe_terminal_term_01g_verify` workaround was rejected by the operator as a maintenance burden; never repeat it for TERM-01G-C.
