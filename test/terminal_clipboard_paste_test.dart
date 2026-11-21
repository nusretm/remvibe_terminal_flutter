import 'package:flutter_test/flutter_test.dart';
import 'package:remvibe_terminal_flutter/src/terminal_clipboard_paste.dart';

void main() {
  test('preserves Unicode while sending each scalar separately', () async {
    final calls = <String>[];
    final count = await sendTerminalClipboardText(
      text: 'a😀é',
      send: (character) { calls.add(character); return null; },
      isSessionCurrent: () => true,
      characterDelay: Duration.zero,
      newlineDelay: Duration.zero,
    );
    expect(calls, ['a', '😀', 'é']);
    expect(count, 3);
  });

  test('normalizes CRLF and LF into exactly one terminal Enter', () async {
    final calls = <String>[];
    final count = await sendTerminalClipboardText(
      text: 'one\r\ntwo\nthree\rfour',
      send: (character) { calls.add(character); return null; },
      isSessionCurrent: () => true,
      characterDelay: Duration.zero,
      newlineDelay: Duration.zero,
    );
    expect(calls.join(), 'one\rtwo\rthree\rfour');
    expect(calls.where((char) => char == '\r').length, 3);
    expect(count, calls.length);
  });

  test('stops sending if the terminal session is replaced', () async {
    final calls = <String>[];
    await expectLater(
      sendTerminalClipboardText(
        text: 'abcdefgh',
        send: (character) { calls.add(character); return null; },
        isSessionCurrent: () => calls.length < 2,
        characterDelay: Duration.zero,
        newlineDelay: Duration.zero,
      ),
      throwsA(isA<StateError>()),
    );
    expect(calls, ['a', 'b']);
  });

  test('rejects invalid delays before sending anything', () async {
    final calls = <String>[];
    await expectLater(
      sendTerminalClipboardText(
        text: 'hello',
        send: (character) { calls.add(character); return null; },
        isSessionCurrent: () => true,
        characterDelay: const Duration(milliseconds: -1),
      ),
      throwsArgumentError,
    );
    expect(calls, isEmpty);
  });
}
