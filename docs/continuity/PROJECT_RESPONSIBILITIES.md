# remvibe_terminal_flutter — responsibility and scope gate

Status: Binding responsibility boundary; initialized 2026-11-21. TERM-01G-C UI-only implementation has been agreed by the operator and committed on its feature branch, but Windows and Ubuntu technical/product acceptance are still pending. The document remains a mandatory scope gate.

## Mission

A standalone reusable Flutter terminal **viewer** that receives a transport-agnostic `TerminalHandler` from the `remvibe_terminal` package. No terminal engine, service orchestration or network transport belongs here.

## Owned UI responsibilities

1. One independent xterm2 `Terminal` display model per widget/pane, with ANSI/VT output rendering and UTF-8 byte-stream decoding.
2. Keyboard focus/input, cursor, per-view selection, scrollback and mouse interactions.
3. Already-tested Windows UX: anchored long-scrollback selection; right-click copy/clear and scroll to cursor; explicit confirmation before clipboard paste; Unicode scalar-by-scalar input and normalized newline/Enter behavior.
4. Latest-wins terminal cell resize coordination and error presentation. Native terminal resize happens only through the supplied handler's existing authorization/control semantics.
5. Subscribe/unsubscribe to handler state/output on widget mount/disposal. Replay/gap reports are surfaced. Disposal releases only its observer/visual resources; it NEVER terminates a PTY or silently takes controller ownership.
6. Support multiple simultaneous terminal panes: two independent PTYs, plus two independent viewers of one PTY. Each pane has its own display state and selection.
7. Focused widget and helper tests, sample integration and actual Windows Flutter Debug operator verification.

## Other owners

- `nusretm/remvibe_terminal`: native ConPTY, process and session ownership, create/attach/detach/terminate, session discovery, typed `TerminalHandler` API, local implementation, replay/sequence/gap and work state.
- `nusretm/remvibe_update_center`: eventual `TerminalHandlerRemote`, device auth, Networking, Console/Server/Client orchestration and routing, notification delivery, Fleet and Windows SCM.
- The host application: chooses which handler/session a pane displays, owns selected session and any explicit destructive session actions.

## Non-goals and approval boundary

No native DLLs, PTYs, networking, device discovery, authorization, remote adapters, SCM, installation/signing/update engines, Fleet features, command-activity classifier, speculative operating-system ports or unrelated UI features.

A responsibility outside this document requires a **written, separately approved owner/scope plan** before implementation. The presence of this file and a branch is not permission to implement TERM-01G-C. Technical test success is not authorization to merge/release.

The reference `remvibe_terminal` branch is operator-accepted for TERM-01G-B local Windows functionality; the new Flutter package has no runtime acceptance yet. Preserve reference code/behavior until the new consumer works in real Windows.
