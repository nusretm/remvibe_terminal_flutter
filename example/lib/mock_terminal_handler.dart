import 'dart:async';
import 'dart:convert';

import 'package:remvibe_terminal/remvibe_terminal.dart';

/// Explicitly simulated UI-only source for Linux widget verification.
/// This does NOT start a shell, PTY or OS process.
final class MockTerminalHandler implements TerminalHandler {
  MockTerminalHandler(this.terminalId);

  @override
  final String terminalId;

  final Map<TerminalHandlerRegistration,
      ({TerminalStateCallback? state, TerminalStreamCallback? stream})>
      _watchers = {};
  int _sequence = 0;
  final List<TerminalStreamEvent> _history = [];

  @override
  TerminalHandlerRegistration registerHandler({
    TerminalStateCallback? onTerminalState,
    TerminalStreamCallback? onTerminalStream,
    int afterSequence = 0,
  }) {
    final token = TerminalHandlerRegistration();
    _watchers[token] = (state: onTerminalState, stream: onTerminalStream);
    for (final event in _history) {
      if (event.sequence <= afterSequence) continue;
      onTerminalStream?.call(
        this,
        TerminalStreamEvent.output(
          terminalId: terminalId,
          sequence: event.sequence,
          bytes: event.bytes,
          replayed: true,
        ),
      );
    }
    return token;
  }

  @override
  Future<void> unregisterHandler(TerminalHandlerRegistration token) async {
    _watchers.remove(token);
  }

  void writeDemo(String text) {
    final event = TerminalStreamEvent.output(
      terminalId: terminalId,
      sequence: ++_sequence,
      bytes: utf8.encode(text),
    );
    _history.add(event);
    if (_history.length > 64) _history.removeAt(0);
    for (final watcher in _watchers.values.toList()) {
      watcher.stream?.call(this, event);
    }
  }

  @override
  Future<void> input(List<int> bytes) async {
    writeDemo('\r\n[UI mock only — input is not executed] '
        '${utf8.decode(bytes, allowMalformed: true)}\r\n');
  }

  @override
  Future<void> resize({required int columns, required int rows}) async {}

  @override
  Future<void> interrupt() async => writeDemo('^C (UI mock only)\r\n');

  @override
  Future<void> detach() async {}
}
