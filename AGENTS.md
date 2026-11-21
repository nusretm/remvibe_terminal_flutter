# remvibe_terminal_flutter — Working rules

**TERM-02B Ubuntu real Bash GUI feature accepted, follow-up gates PASS (2026-11-21):** Real Linux PTY core pinned at `e415608878daaa16b0d0ba1eaab3a2c272f3fe4b` (**35/35 native core tests and real dual-Bash smoke PASS**). Flutter feature previously demonstrated real Bash GUI at `8b745ab` (operator acceptance). TERM-02B-GAP-01 at `d1bb20b99d5f4bfb94494d50fd22caff5a82c0d4` passed Ubuntu Flutter analyzer, **15/15 widget tests**, example analyzer, **1/1 test**, Linux Debug build and exit 0. TERM-02B-BASH-PROMPT-01 example-only Bash startup change was then operator-tested at `89e6808e609272d4d9961b5166dbe2279a33185b`: example analyzer clean, 1/1 test PASS, Linux Debug build PASS (exit 0), GUI screenshot shows two configured colored Bash prompts and `Watching` under both; user confirmed all interactions worked. No gap visible in latest GUI, but historical replay-gap reason is not fully proven, and no assertion of universal lossless replay is made. The old named stash and generated Flutter runner files remain protected; **no merge/release/cleanup/SCM/Update Center/remote handler changes**. See `docs/continuity/TERM_02B_LINUX_REAL_GUI.md`.


**Current state (2026-11-21): TERM-01G-C WINDOWS AND UBUNTU FLUTTER VIEWER SCOPE ACCEPTED.** Windows: root 12/12 and example 1/1 tests, real ConPTY two-terminal/mirrored-view/same-PID reattach, clipboard/selection/resize PASS. Ubuntu: Linux Debug build, example analyzer/test, two UI-mock panes, reversible shared-viewer toggle, selection/copy, paste/confirmation and resize PASS (operator verified). Native Linux PTY or real Bash is **NOT implemented**. No main merge, release, deployment or cleanup.

**TERM-02B-GAP-01:** Ubuntu 15/15 widget tests and Linux Debug build PASS at `d1bb20b`; recent real GUI screenshot shows both panes `Watching` without a gap message. Historical replay truncation cause remains unknown; do not disable the gap detector.

**TERM-02B-BASH-PROMPT-01:** Ubuntu operator acceptance PASS at `89e6808` for example-only `exec /bin/bash -i`. Both real panes show configured user prompt automatically, no hard-coded PS1. Keep core's reproducible smoke command unchanged.

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
