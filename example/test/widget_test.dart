import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:remvibe_terminal/remvibe_terminal.dart';
import 'package:remvibe_terminal_flutter_example/mock_terminal_handler.dart';

void main() {
  test('UI mock supports independent viewers, replay and unregister', () async {
    final handler = MockTerminalHandler('ui-mock');
    final first = <TerminalStreamEvent>[];
    final second = <TerminalStreamEvent>[];

    final firstToken = handler.registerHandler(
      onTerminalStream: (_, event) => first.add(event),
    );

    handler.writeDemo('initial');
    expect(first, hasLength(1));
    expect(utf8.decode(first.single.bytes), 'initial');
    expect(first.single.replayed, isFalse);

    final secondToken = handler.registerHandler(
      onTerminalStream: (_, event) => second.add(event),
    );
    expect(second, hasLength(1));
    expect(utf8.decode(second.single.bytes), 'initial');
    expect(second.single.replayed, isTrue);

    handler.writeDemo('live');
    expect(first.map((event) => event.sequence), [1, 2]);
    expect(second.map((event) => event.sequence), [1, 2]);
    expect(second.last.replayed, isFalse);

    await handler.unregisterHandler(firstToken);
    handler.writeDemo('after unregister');
    expect(first, hasLength(2));
    expect(second, hasLength(3));
    expect(utf8.decode(second.last.bytes), 'after unregister');

    await handler.unregisterHandler(secondToken);
  });
}
