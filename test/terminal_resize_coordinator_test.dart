import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remvibe_terminal_flutter/src/terminal_resize_coordinator.dart';

void main() {
  test('coalesces requests but applies the newest one after settling', () {
    fakeAsync((time) {
      final origin = DateTime.utc(2026, 11, 20);
      final applied = <TerminalDimensions>[];
      final queue = TerminalResizeCoordinator(
        initialSize: (columns: 60, rows: 20),
        applyResize: (size) { applied.add(size); return null; },
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
        clock: () => origin.add(time.elapsed),
        tickInterval: const Duration(milliseconds: 5),
        requestDebounce: const Duration(milliseconds: 40),
        quietWindow: const Duration(milliseconds: 100),
        maximumCoalesceWait: const Duration(milliseconds: 300),
      );

      queue.request(columns: 80, rows: 24);
      time.elapse(const Duration(milliseconds: 20));
      queue.request(columns: 100, rows: 30);
      time.elapse(const Duration(milliseconds: 20));
      queue.request(columns: 120, rows: 40);
      time.elapse(const Duration(milliseconds: 60));
      expect(applied, [(columns: 120, rows: 40)]);

      queue.request(columns: 90, rows: 30);
      queue.request(columns: 140, rows: 45);
      time.elapse(const Duration(milliseconds: 50));
      // Prior native resize is still settling. No request has been discarded.
      expect(applied, [(columns: 120, rows: 40)]);
      expect(queue.pendingSize, (columns: 140, rows: 45));

      time.elapse(const Duration(milliseconds: 100));
      expect(applied, [
        (columns: 120, rows: 40),
        (columns: 140, rows: 45),
      ]);
      queue.dispose();
    });
  });

  test('continuous output cannot starve the last pending resize', () {
    fakeAsync((time) {
      final origin = DateTime.utc(2026, 11, 20);
      final applied = <TerminalDimensions>[];
      final queue = TerminalResizeCoordinator(
        initialSize: (columns: 60, rows: 20),
        applyResize: (size) { applied.add(size); return null; },
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
        clock: () => origin.add(time.elapsed),
        tickInterval: const Duration(milliseconds: 5),
        requestDebounce: const Duration(milliseconds: 20),
        quietWindow: const Duration(milliseconds: 100),
        outputBusyGrace: const Duration(milliseconds: 60),
        maximumSettleWait: const Duration(milliseconds: 300),
      );
      queue.request(columns: 80, rows: 24);
      time.elapse(const Duration(milliseconds: 50));
      expect(applied, [(columns: 80, rows: 24)]);

      queue.request(columns: 100, rows: 30);
      for (var index = 0; index < 8; index++) {
        queue.reportOutput(cursorColumn: index, cursorRow: 3);
        if (index == 4) {
          queue.request(columns: 140, rows: 45);
        }
        time.elapse(const Duration(milliseconds: 50));
      }

      expect(applied.last, (columns: 140, rows: 45));
      expect(applied.length, 2);
      queue.dispose();
    });
  });

  test('resizing to the current applied size does not issue duplicate calls', () {
    fakeAsync((time) {
      final origin = DateTime.utc(2026, 11, 20);
      final applied = <TerminalDimensions>[];
      final queue = TerminalResizeCoordinator(
        initialSize: (columns: 100, rows: 30),
        applyResize: (size) { applied.add(size); return null; },
        onError: (error, stackTrace) => fail('Unexpected error: $error'),
        clock: () => origin.add(time.elapsed),
        requestDebounce: const Duration(milliseconds: 20),
        tickInterval: const Duration(milliseconds: 5),
      );
      queue.request(columns: 100, rows: 30);
      time.elapse(const Duration(milliseconds: 100));
      expect(applied, isEmpty);
      queue.dispose();
      expect(queue.isDisposed, isTrue);
    });
  });

  test('remote async resize ACK never overlaps next requested size', () {
    fakeAsync((time) {
      final firstAck = Completer<void>();
      final origin = DateTime.utc(2026, 11, 20);
      final requested = <TerminalDimensions>[];
      final coordinator = TerminalResizeCoordinator(
        initialSize: (columns: 80, rows: 24),
        applyResize: (size) {
          requested.add(size);
          if (requested.length == 1) return firstAck.future;
          return null;
        },
        onError: (error, trace) => fail('Unexpected error: $error'),
        clock: () => origin.add(time.elapsed),
        tickInterval: const Duration(milliseconds: 5),
        requestDebounce: const Duration(milliseconds: 10),
        quietWindow: const Duration(milliseconds: 20),
      );

      coordinator.request(columns: 90, rows: 25);
      time.elapse(const Duration(milliseconds: 40));
      expect(requested, [(columns: 90, rows: 25)]);

      coordinator.request(columns: 110, rows: 30);
      coordinator.request(columns: 130, rows: 35);
      time.elapse(const Duration(milliseconds: 200));
      // Remote hasn't ACKed first resize: latest target remains pending.
      expect(requested.length, 1);
      expect(coordinator.pendingSize, (columns: 130, rows: 35));

      firstAck.complete();
      time.flushMicrotasks();
      time.elapse(const Duration(milliseconds: 60));
      expect(requested, [
        (columns: 90, rows: 25),
        (columns: 130, rows: 35),
      ]);
      coordinator.dispose();
    });
  });

}
