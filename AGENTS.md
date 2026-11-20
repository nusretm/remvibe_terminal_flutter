# remvibe_terminal_flutter — Working rules

**Current state (2026-11-21):** Independent repository initialized. TERM-01G-C is **planning only**; Flutter viewer extraction has NOT been approved, coded, tested, or accepted.

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
- TERM-01G-C requires **separate explicit operator implementation approval**. Creating this repository or planning files is not code authorization. Use a feature branch; Windows analyzer/tests, real two-terminal/two-viewer Debug demonstration and explicit operator acceptance are required before merging or releasing.
- No automatic PR merge, release, package publication, deployment or cleanup.
