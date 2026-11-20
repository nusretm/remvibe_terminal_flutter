import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remvibe_terminal/remvibe_terminal.dart';
import 'package:remvibe_terminal_flutter/remvibe_terminal_flutter.dart';

final class _FakeHandler implements TerminalHandler {
  _FakeHandler(this.terminalId);

  @override
  final String terminalId;

  final Map<TerminalHandlerRegistration,
      ({TerminalStateCallback? state, TerminalStreamCallback? stream})>
      subscriptions = {};

  int unregisterCalls = 0;
  int detachCalls = 0;
  int inputCalls = 0;
  int interruptCalls = 0;
  int resizeCalls = 0;

  @override
  TerminalHandlerRegistration registerHandler({
    TerminalStateCallback? onTerminalState,
    TerminalStreamCallback? onTerminalStream,
    int afterSequence = 0,
  }) {
    final token = TerminalHandlerRegistration();
    subscriptions[token] =
        (state: onTerminalState, stream: onTerminalStream);
    return token;
  }

  @override
  Future<void> unregisterHandler(TerminalHandlerRegistration registration) async {
    unregisterCalls++;
    subscriptions.remove(registration);
  }

  void emitBytes(List<int> bytes, int sequence) {
    final event = TerminalStreamEvent.output(
      terminalId: terminalId,
      sequence: sequence,
      bytes: bytes,
    );
    for (final callback in subscriptions.values.toList()) {
      callback.stream?.call(this, event);
    }
  }

  void emitGap(int from, int to) {
    final event = TerminalStreamEvent.gap(
      terminalId: terminalId,
      fromSequence: from,
      toSequence: to,
    );
    for (final callback in subscriptions.values.toList()) {
      callback.stream?.call(this, event);
    }
  }

  void emitExit(int code) {
    final event = TerminalStateEvent(
      terminalId: terminalId,
      kind: TerminalStateEventKind.exited,
      timestampUtc: DateTime.utc(2026, 11, 21),
      commandState: TerminalCommandState.idle,
      controllerAttached: false,
      exitCode: code,
    );
    for (final callback in subscriptions.values.toList()) {
      callback.state?.call(this, event);
    }
  }

  @override
  Future<void> input(List<int> bytes) async {
    inputCalls++;
  }

  @override
  Future<void> resize({required int columns, required int rows}) async {
    resizeCalls++;
  }

  @override
  Future<void> interrupt() async {
    interruptCalls++;
  }

  @override
  Future<void> detach() async {
    detachCalls++;
  }
}

Widget _harness(Widget child) => MaterialApp(
  home: Scaffold(
    body: SizedBox(width: 900, height: 600, child: child),
  ),
);

void main() {
  testWidgets('two independent viewers on one PTY unregister separately',
      (tester) async {
    final handler = _FakeHandler('one');
    await tester.pumpWidget(_harness(Row(children: [
      Expanded(
        child: RemVibeTerminalWidget(
          key: const ValueKey('pane-a'),
          handler: handler,
          label: 'First pane',
          autofocus: false,
        ),
      ),
      Expanded(
        child: RemVibeTerminalWidget(
          key: const ValueKey('pane-b'),
          handler: handler,
          label: 'Second pane',
          readOnly: true,
          autofocus: false,
        ),
      ),
    ])));
    expect(handler.subscriptions, hasLength(2));
    expect(find.text('First pane'), findsOneWidget);
    expect(find.text('Second pane'), findsOneWidget);

    handler.emitBytes(utf8.encode('Shared output'), 1);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_harness(
      RemVibeTerminalWidget(
        key: const ValueKey('pane-a'),
        handler: handler,
        label: 'First pane',
        autofocus: false,
      ),
    ));
    await tester.pump();
    expect(handler.subscriptions, hasLength(1));
    expect(handler.unregisterCalls, 1);
    expect(handler.detachCalls, 0);
    expect(find.text('First pane'), findsOneWidget);

    handler.emitBytes(utf8.encode('Still running'), 2);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(handler.subscriptions, isEmpty);
    expect(handler.unregisterCalls, 2);
    expect(handler.detachCalls, 0);
  });

  testWidgets('read-only viewer disables interrupt without claiming control',
      (tester) async {
    final handler = _FakeHandler('read-only');
    await tester.pumpWidget(_harness(RemVibeTerminalWidget(
      handler: handler,
      label: 'Read-only',
      autofocus: false,
      readOnly: true,
    )));
    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    expect(handler.inputCalls, 0);
    expect(handler.resizeCalls, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(handler.detachCalls, 0);
  });

  testWidgets('reports missing frames and real exit once', (tester) async {
    final handler = _FakeHandler('gap');
    final exits = <int?>[];
    await tester.pumpWidget(_harness(RemVibeTerminalWidget(
      handler: handler,
      autofocus: false,
      onExit: exits.add,
    )));
    handler.emitGap(1, 4);
    handler.emitBytes(utf8.encode('after gap'), 5);
    await tester.pump();
    expect(find.textContaining('incomplete output history'), findsOneWidget);

    handler.emitExit(7);
    handler.emitExit(7);
    await tester.pump();
    expect(exits, [7]);
    expect(find.textContaining('Exited: 7'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('split UTF-8 byte frames do not produce decoder errors',
      (tester) async {
    final handler = _FakeHandler('utf8');
    final errors = <Object>[];
    await tester.pumpWidget(_harness(RemVibeTerminalWidget(
      handler: handler,
      autofocus: false,
      onError: errors.add,
    )));
    final emoji = utf8.encode('😀');
    handler.emitBytes(emoji.sublist(0, 2), 1);
    handler.emitBytes(emoji.sublist(2), 2);
    await tester.pump();
    expect(errors, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
