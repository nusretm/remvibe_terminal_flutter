import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm2/xterm.dart';

/// Keeps a selection's origin anchored to the actual scrollback line.
///
/// xterm2 5.5.0 reinterprets the original viewport-local drag coordinate on
/// each auto-scroll update. That moves the selection origin together with the
/// viewport. This viewer fixes that behavior using only public xterm2 APIs.
/// No modification to ConPTY, terminal engine or xterm2 package is required.
class StableScrollbackTerminalView extends StatefulWidget {
  const StableScrollbackTerminalView(
    this.terminal, {
    super.key,
    this.autofocus = false,
    this.onPasteRequested,
    this.onInteractionError,
  });

  final Terminal terminal;
  final bool autofocus;

  /// Paste is handled by the owning application after explicit confirmation.
  final Future<void> Function()? onPasteRequested;
  final void Function(Object error)? onInteractionError;

  @override
  State<StableScrollbackTerminalView> createState() =>
      _StableScrollbackTerminalViewState();
}

class _StableScrollbackTerminalViewState
    extends State<StableScrollbackTerminalView> {
  final GlobalKey<TerminalViewState> _viewKey =
      GlobalKey<TerminalViewState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _contextActionRunning = false;
  late final _PinnedSelectionController _selection =
      _PinnedSelectionController(widget.terminal);

  int? _mousePointer;
  Offset? _startGlobalPosition;
  Offset? _endGlobalPosition;
  bool _dragSelecting = false;
  bool _scrollUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    _selection.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse ||
        event.buttons & kPrimaryMouseButton == 0) {
      return;
    }
    _mousePointer = event.pointer;
    _startGlobalPosition = event.position;
    _endGlobalPosition = event.position;
    _dragSelecting = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _mousePointer ||
        event.buttons & kPrimaryMouseButton == 0) {
      return;
    }

    if (!_dragSelecting) {
      final start = _startGlobalPosition;
      if (start == null || (event.position - start).distanceSquared < 16) {
        return;
      }
      final render = _viewKey.currentState?.renderTerminal;
      if (render == null) return;
      final begin = render.getCellOffset(render.globalToLocal(start));
      _selection.beginDrag(begin);
      _dragSelecting = true;
    }

    _endGlobalPosition = event.position;
    _updateSelection();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _mousePointer) return;
    if (_dragSelecting) {
      _endGlobalPosition = event.position;
      _updateSelection();
      _selection.endDrag();
    }
    _clearPointer();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _mousePointer) return;
    _selection.endDrag();
    _clearPointer();
  }

  void _clearPointer() {
    _mousePointer = null;
    _startGlobalPosition = null;
    _endGlobalPosition = null;
    _dragSelecting = false;
  }

  void _onScroll() {
    if (!_dragSelecting || _scrollUpdateScheduled) return;
    _scrollUpdateScheduled = true;
    // Let xterm2 perform its own scroll and drag callbacks first. Then repair
    // the selection using the pinned buffer anchor and current viewport.
    scheduleMicrotask(() {
      _scrollUpdateScheduled = false;
      if (mounted && _dragSelecting) _updateSelection();
    });
  }

  void _updateSelection() {
    final point = _endGlobalPosition;
    final render = _viewKey.currentState?.renderTerminal;
    if (point == null || render == null || !_dragSelecting) return;
    final cell = render.getCellOffset(render.globalToLocal(point));
    _selection.extendDrag(cell);
  }

  Future<void> _handleSecondaryTapUp() async {
    if (_contextActionRunning) return;
    _contextActionRunning = true;
    try {
      final buffer = widget.terminal.buffer;
      final selection = _selection.selectionFor(buffer);
      if (selection != null) {
        // Follow xterm2's own copy semantics, preserving soft-wrapped lines.
        final text = buffer.getText(selection, true);
        await Clipboard.setData(ClipboardData(text: text));
        if (!mounted) return;
        _selection.clearSelection();
        _scrollToCursor();
      } else {
        await widget.onPasteRequested?.call();
      }
      if (mounted) _focusNode.requestFocus();
    } catch (error) {
      widget.onInteractionError?.call(error);
    } finally {
      _contextActionRunning = false;
    }
  }

  void _scrollToCursor() {
    if (!_scrollController.hasClients) return;
    final render = _viewKey.currentState?.renderTerminal;
    if (render == null) return;
    final position = _scrollController.position;
    final lineHeight = render.lineHeight;
    final cursorTop = widget.terminal.buffer.absoluteCursorY * lineHeight;
    final cursorBottom = cursorTop + lineHeight;
    final top = position.pixels;
    final bottom = top + position.viewportDimension;

    // Bring the actual cursor into view without unnecessarily discarding
    // the user's scroll position when the cursor is already visible.
    final double destination;
    if (cursorTop < top) {
      destination = cursorTop;
    } else if (cursorBottom > bottom) {
      destination = cursorBottom - position.viewportDimension;
    } else {
      return;
    }
    position.jumpTo(
      destination.clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: TerminalView(
        widget.terminal,
        key: _viewKey,
        controller: _selection,
        scrollController: _scrollController,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onSecondaryTapUp: (details, cell) {
          unawaited(_handleSecondaryTapUp());
        },
        onPaste: widget.onPasteRequested,
      ),
    );
  }
}

/// Prevent xterm2's stale viewport-coordinate drag callbacks from overwriting
/// the persistent anchor. Normal click/word/line selection stays with xterm2.
class _PinnedSelectionController extends TerminalController {
  _PinnedSelectionController(this._terminal);

  final Terminal _terminal;
  CellAnchor? _pinnedStart;
  bool _dragActive = false;

  void beginDrag(CellOffset cell) {
    endDrag();
    final buffer = _terminal.buffer;
    if (buffer.lines.length == 0) return;
    _pinnedStart = buffer.createAnchorFromOffset(cell);
    _dragActive = true;
  }

  void extendDrag(CellOffset target) {
    final pinned = _pinnedStart;
    final buffer = _terminal.buffer;
    if (!_dragActive || pinned == null || !buffer.ownsAnchor(pinned)) {
      return;
    }

    final origin = pinned.offset;
    final forward = target.isAfterOrSame(origin);
    final begin = forward ? origin : _cellEnd(origin);
    final end = forward ? _cellEnd(target) : target;
    // Calling super here is intentional: the controller owns these *new*
    // anchors and disposes them when the selection changes. Our pinned
    // scrollback anchor stays separate until mouse-up.
    super.setSelection(
      buffer.createAnchorFromOffset(begin),
      buffer.createAnchorFromOffset(end),
      mode: SelectionMode.line,
    );
  }

  CellOffset _cellEnd(CellOffset cell) {
    final line = _terminal.buffer.lines[cell.y];
    final width = line.getWidth(cell.x) == 2 ? 2 : 1;
    return CellOffset(min(cell.x + width, _terminal.viewWidth), cell.y);
  }

  @override
  void setSelection(
    CellAnchor base,
    CellAnchor extent, {
    SelectionMode? mode,
  }) {
    if (_dragActive) {
      // These two anchors came from the buggy viewport-local xterm2 drag
      // calculation. It passes ownership to the controller; dispose both.
      base.dispose();
      extent.dispose();
      return;
    }
    super.setSelection(base, extent, mode: mode);
  }

  void endDrag() {
    _dragActive = false;
    _pinnedStart?.dispose();
    _pinnedStart = null;
  }

  @override
  void dispose() {
    endDrag();
    super.dispose();
  }
}
