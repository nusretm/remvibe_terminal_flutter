import 'dart:async';

/// Sends clipboard content to an interactive PTY one Unicode scalar at a time.
///
/// CRLF and lone LF/CR become a single terminal Enter (CR). This prevents
/// Windows clipboard line endings from emitting two Enter events and allows
/// the interactive shell to process each key in sequence.
///
/// There is deliberately no bracketed-paste escape sequence: the current
/// PowerShell/CMD example uses the same character-by-character behavior
/// that was previously reliable in the operator's terminal workflows.
Future<int> sendTerminalClipboardText({
  required String text,
  required Future<void>? Function(String character) send,
  required bool Function() isSessionCurrent,
  Duration characterDelay = const Duration(milliseconds: 3),
  Duration newlineDelay = const Duration(milliseconds: 35),
}) async {
  if (characterDelay.isNegative || newlineDelay.isNegative) {
    throw ArgumentError('Paste delays must not be negative.');
  }

  final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  var sent = 0;
  for (final rune in normalized.runes) {
    if (!isSessionCurrent()) {
      throw StateError('Terminal session closed or changed during paste.');
    }
    final isNewline = rune == 10;
    final character = isNewline ? '\r' : String.fromCharCode(rune);
    final result = send(character);
    if (result != null) await result;
    sent++;
    // Yield to the event loop between individual PTY writes. An extra pause
    // after Enter lets the shell advance the prompt before the next line.
    await Future<void>.delayed(isNewline ? newlineDelay : characterDelay);
  }
  return sent;
}
