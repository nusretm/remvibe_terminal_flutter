import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remvibe_terminal/remvibe_terminal.dart';
import 'package:xterm2/xterm.dart';

import 'stable_scrollback_terminal_view.dart';
import 'terminal_clipboard_paste.dart';
import 'terminal_resize_coordinator.dart';

/// Reusable Flutter terminal over a transport-neutral TerminalHandler.
/// Owns the per-pane xterm display and observer only; never owns the PTY.
class RemVibeTerminalWidget extends StatefulWidget {
  const RemVibeTerminalWidget({
    super.key,
    required this.handler,
    this.label,
    this.readOnly = false,
    this.initialColumns = 80,
    this.initialRows = 24,
    this.autofocus = true,
    this.showToolbar = true,
    this.onError,
    this.onExit,
  });

  final TerminalHandler handler;
  final String? label;

  /// UI-only hint; handler remains authoritative for control.
  final bool readOnly;
  final int initialColumns;
  final int initialRows;
  final bool autofocus;
  final bool showToolbar;
  final void Function(Object error)? onError;
  final void Function(int? exitCode)? onExit;

  @override
  State<RemVibeTerminalWidget> createState() => _RemVibeTerminalWidgetState();
}

class _RemVibeTerminalWidgetState extends State<RemVibeTerminalWidget> {
  late final Terminal _terminal = Terminal(
    maxLines: 5000,
    windowsPtyMode: true,
    onOutput: _onTerminalInput,
    onResize: (columns, rows, pixelWidth, pixelHeight) {
      if (!widget.readOnly) _resize.request(columns: columns, rows: rows);
    },
  );

  late final TerminalResizeCoordinator _resize = TerminalResizeCoordinator(
    initialSize: (
      columns: widget.initialColumns,
      rows: widget.initialRows,
    ),
    applyResize: (size) => widget.handler.resize(
      columns: size.columns,
      rows: size.rows,
    ),
    onError: (error, trace) => _reportError(error),
  );

  StreamSubscription<String>? _output;
  StreamController<List<int>>? _outputBytes;
  TerminalHandlerRegistration? _registration;
  bool _exitReported = false;
  Future<void> _inputQueue = Future<void>.value();
  bool _pasting = false;
  bool _cancelPaste = false;
  bool _detached = false;
  String _status = 'Watching';
  int? _lastSequence;
  bool _outputGap = false;

  @override
  void initState() {
    super.initState();
    _subscribeOutput();
  }

  @override
  void didUpdateWidget(covariant RemVibeTerminalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(
      identical(oldWidget.handler, widget.handler),
      'Use a new widget key for each terminal attachment.',
    );
  }

  void _subscribeOutput() {
    // Keep one incremental decoder per visible viewport. UTF-8 sequences
    // may be split between TerminalStreamEvent output frames.
    final bytes = StreamController<List<int>>(sync: true);
    _outputBytes = bytes;
    _output = bytes.stream.transform(const Utf8Decoder(allowMalformed: true)).listen(
      (data) {
        if (!mounted || _detached || data.isEmpty) return;
        _terminal.write(data);
        _resize.reportOutput(
          cursorColumn: _terminal.buffer.cursorX,
          cursorRow: _terminal.buffer.cursorY,
        );
      },
      onError: (Object error, StackTrace trace) => _reportError(error),
    );

    _registration = widget.handler.registerHandler(
      onTerminalState: (_, event) => _handleState(event),
      onTerminalStream: (_, event) {
        if (!mounted || _detached) return;
        if (event.isGap) {
          _lastSequence = event.sequence;
          _outputGap = true;
          _setStatus('Output sequence gap: incomplete history');
          return;
        }
        final previous = _lastSequence;
        if (previous != null && event.sequence <= previous) return;
        if (previous != null && event.sequence != previous + 1) {
          _outputGap = true;
          _setStatus('Output sequence gap: incomplete history');
        }
        _lastSequence = event.sequence;
        bytes.add(event.bytes);
      },
    );
  }

  void _handleState(TerminalStateEvent event) {
    if (!mounted || _detached) return;
    switch (event.kind) {
      case TerminalStateEventKind.exited:
      case TerminalStateEventKind.terminated:
      case TerminalStateEventKind.expired:
        final reason = switch (event.kind) {
          TerminalStateEventKind.exited => 'Exited',
          TerminalStateEventKind.terminated => 'Terminated',
          TerminalStateEventKind.expired => 'Expired',
          _ => 'Closed',
        };
        _setStatus(event.exitCode == null
            ? reason
            : '$reason: ${event.exitCode}');
        if (!_exitReported) {
          _exitReported = true;
          widget.onExit?.call(event.exitCode);
        }
        return;
      case TerminalStateEventKind.detached:
        _setStatus('Controller detached • still watching');
        return;
      case TerminalStateEventKind.attached:
        _setStatus(widget.readOnly ? 'Read-only viewer' : 'Watching');
        return;
      case TerminalStateEventKind.created:
      case TerminalStateEventKind.snapshot:
      case TerminalStateEventKind.commandActivityChanged:
        return;
    }
  }

  void _setStatus(String value) {
    if (mounted) setState(() => _status = value);
  }

  void _reportError(Object error) {
    if (!mounted || _detached) return;
    _setStatus('Terminal error: $error');
    widget.onError?.call(error);
  }

  void _onTerminalInput(String text) {
    if (_detached || widget.readOnly || _pasting || text.isEmpty) return;
    final session = widget.handler;
    final bytes = utf8.encode(text);
    // Keep async remote input operations in their original keyboard order.
    _inputQueue = _inputQueue.then((_) async {
      if (!mounted || _detached || _pasting) return;
      await session.input(bytes);
    }).catchError((Object error, StackTrace trace) {
      _reportError(error);
    });
  }

  Future<void> _interrupt() async {
    _cancelPaste = true;
    if (widget.readOnly) return;
    try {
      await widget.handler.interrupt();
    } catch (error) {
      _reportError(error);
    }
  }

  Future<void> _requestClipboardPaste() async {
    if (_pasting || _detached || widget.readOnly || !mounted) return;
    _cancelPaste = false;
    setState(() => _pasting = true);
    try {
      final clip = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || _detached) return;
      final text = clip?.text ?? '';
      if (text.isEmpty) {
        _setStatus('Clipboard is empty');
        return;
      }

      final lines = RegExp(r'\r\n|\n|\r').allMatches(text).length + 1;
      final preview = text.length > 420
          ? '${text.substring(0, 420)}…'
          : text;
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Paste into terminal?'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${text.runes.length} characters, $lines line(s). '
                  'Newlines may execute commands.',
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      preview,
                      style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Paste'),
            ),
          ],
        ),
      );

      if (approved != true || !mounted || _detached || _cancelPaste) return;
      await _inputQueue;
      if (!mounted || _detached || _cancelPaste) return;

      _setStatus('Pasting characters...');
      final session = widget.handler;
      final count = await sendTerminalClipboardText(
        text: text,
        isSessionCurrent: () => mounted && !_detached && !_cancelPaste,
        send: (character) => session.input(utf8.encode(character)),
      );
      if (mounted && !_detached) {
        _setStatus('Pasted $count characters');
      }
    } catch (error) {
      if (mounted && !_detached) _reportError(error);
    } finally {
      if (mounted) setState(() => _pasting = false);
    }
  }

  @override
  void dispose() {
    _detached = true;
    _cancelPaste = true;
    _resize.dispose();
    final output = _output;
    if (output != null) unawaited(output.cancel());
    final token = _registration;
    if (token != null) unawaited(widget.handler.unregisterHandler(token));
    final bytes = _outputBytes;
    if (bytes != null) unawaited(bytes.close());
    _terminal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showToolbar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label ?? widget.handler.terminalId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Ctrl+C (interrupt)',
                  onPressed: widget.readOnly ? null : _interrupt,
                  icon: const Icon(Icons.keyboard_control_key),
                ),
              ],
            ),
          ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: ColoredBox(
              color: const Color(0xFF0C1016),
              child: StableScrollbackTerminalView(
                _terminal,
                autofocus: widget.autofocus,
                onPasteRequested: _requestClipboardPaste,
                onInteractionError: _reportError,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
          child: Text(
            _outputGap ? '$_status • incomplete output history' : _status,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
