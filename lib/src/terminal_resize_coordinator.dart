import 'dart:async';

/// Platform-independent size, in character cells.
typedef TerminalDimensions = ({int columns, int rows});

/// Latest-wins ConPTY resize coordinator for the interactive example.
///
/// ResizePseudoConsole returns when the request is accepted, not when every
/// asynchronous redraw byte has been delivered. A settled resize is therefore
/// only a *heuristic*: no output and no cursor movement for [quietWindow], or
/// a bounded [maximumSettleWait] during continuous output.
///
/// Every incoming size replaces only the PENDING size. A resize already
/// issued to the native API is allowed to settle; then the latest pending size
/// is applied. Requests are never silently discarded for being "in flight".
class TerminalResizeCoordinator {
  TerminalResizeCoordinator({
    required this.applyResize,
    required TerminalDimensions initialSize,
    required this.onError,
    this.requestDebounce = const Duration(milliseconds: 120),
    this.maximumCoalesceWait = const Duration(milliseconds: 500),
    this.outputBusyGrace = const Duration(milliseconds: 350),
    this.quietWindow = const Duration(milliseconds: 250),
    this.maximumSettleWait = const Duration(milliseconds: 1000),
    this.tickInterval = const Duration(milliseconds: 25),
    DateTime Function()? clock,
  })  : _lastApplied = initialSize,
        _clock = clock ?? DateTime.now;

  final Future<void>? Function(TerminalDimensions) applyResize;
  final void Function(Object error, StackTrace stackTrace) onError;
  final Duration requestDebounce;
  final Duration maximumCoalesceWait;
  final Duration outputBusyGrace;
  final Duration quietWindow;
  final Duration maximumSettleWait;
  final Duration tickInterval;
  final DateTime Function() _clock;

  TerminalDimensions _lastApplied;
  TerminalDimensions? _latestPending;
  DateTime? _pendingSince;
  DateTime? _lastRequestedAt;
  DateTime? _settlingSince;
  DateTime? _lastOutputAt;
  DateTime? _lastCursorChangeAt;
  ({int column, int row})? _lastCursor;
  Timer? _clockTimer;
  bool _disposed = false;
  bool _applying = false;

  TerminalDimensions get lastAppliedSize => _lastApplied;
  TerminalDimensions? get pendingSize => _latestPending;
  bool get isSettling => _settlingSince != null || _applying;
  bool get isDisposed => _disposed;

  void request({required int columns, required int rows}) {
    if (_disposed) return;
    if (columns < 1 || rows < 1 || columns > 32767 || rows > 32767) {
      return;
    }

    final requested = (columns: columns, rows: rows);
    final now = _clock();
    // Always replace the pending target. Even if a resize is settling,
    // the newest requested size must be applied after it completes.
    _latestPending = requested;
    _pendingSince ??= now;
    _lastRequestedAt = now;
    _ensureTicker();
  }

  /// Call after the UI has parsed and applied one native PTY output frame.
  /// Cursor stability alone is not enough: output may repaint in place.
  void reportOutput({required int cursorColumn, required int cursorRow}) {
    if (_disposed) return;
    final now = _clock();
    _lastOutputAt = now;
    final cursor = (column: cursorColumn, row: cursorRow);
    if (_lastCursor != cursor) {
      _lastCursor = cursor;
      _lastCursorChangeAt = now;
    }
  }

  void _ensureTicker() {
    _clockTimer ??= Timer.periodic(tickInterval, (_) => _advance());
  }

  void _advance() {
    if (_disposed || _applying) return;
    final now = _clock();

    final settling = _settlingSince;
    if (settling != null) {
      final hasSettledByOutput = _isQuietAfter(_lastOutputAt, settling, now) &&
          _isQuietAfter(_lastCursorChangeAt, settling, now);
      final hasReachedBound = now.difference(settling) >= maximumSettleWait;

      if (!hasSettledByOutput && !hasReachedBound) return;

      // No redraw callback exists. Permit progress even when a running command
      // never stops generating output, without interrupting its output stream.
      _settlingSince = null;
    }

    final pending = _latestPending;
    final pendingSince = _pendingSince;
    final lastRequest = _lastRequestedAt;
    if (pending == null || pendingSince == null || lastRequest == null) {
      _stopTickerIfIdle();
      return;
    }

    final requestStopped = now.difference(lastRequest) >= requestDebounce;
    final maxCoalesceElapsed =
        now.difference(pendingSince) >= maximumCoalesceWait;
    if (!requestStopped && !maxCoalesceElapsed) return;

    // If a command is producing output, prefer a quiet moment before the
    // first resize, but don't starve the request under continuous output.
    if (_lastOutputAt != null &&
        now.difference(_lastOutputAt!) < quietWindow &&
        now.difference(pendingSince) < outputBusyGrace) {
      return;
    }

    _latestPending = null;
    _pendingSince = null;
    _lastRequestedAt = null;

    if (pending == _lastApplied) {
      _stopTickerIfIdle();
      return;
    }

    try {
      // One native call per settled cycle, always using the latest target.
      // Dart's isolate serializes this synchronous FFI call.
      final result = applyResize(pending);
      if (result != null) {
        // Remote transports acknowledge resize asynchronously. Never issue
        // a second request until this one is acknowledged and settled.
        _applying = true;
        unawaited(_completeAsyncResize(result, pending));
      } else {
        _completeResize(pending);
      }
    } catch (error, stackTrace) {
      dispose();
      onError(error, stackTrace);
    }
  }

  Future<void> _completeAsyncResize(
    Future<void> pendingCall,
    TerminalDimensions dimensions,
  ) async {
    try {
      await pendingCall;
      if (!_disposed) _completeResize(dimensions);
    } catch (error, stackTrace) {
      if (!_disposed) {
        dispose();
        onError(error, stackTrace);
      }
    } finally {
      _applying = false;
    }
  }

  void _completeResize(TerminalDimensions dimensions) {
    if (_disposed) return;
    _lastApplied = dimensions;
    _settlingSince = _clock();
    _ensureTicker();
  }

  bool _isQuietAfter(DateTime? activity, DateTime start, DateTime now) {
    final lastActivity =
        activity == null || activity.isBefore(start) ? start : activity;
    return now.difference(lastActivity) >= quietWindow;
  }

  void _stopTickerIfIdle() {
    if (_latestPending == null && _settlingSince == null) {
      _clockTimer?.cancel();
      _clockTimer = null;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _latestPending = null;
    _pendingSince = null;
    _settlingSince = null;
    _clockTimer?.cancel();
    _clockTimer = null;
  }
}
