import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remvibe_terminal/remvibe_terminal.dart';
import 'package:remvibe_terminal_flutter/remvibe_terminal_flutter.dart';

import 'mock_terminal_handler.dart';

void main() => runApp(const TerminalViewerDemo());

class TerminalViewerDemo extends StatelessWidget {
  const TerminalViewerDemo({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RemVibe Terminal Flutter',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const TerminalViewerHome(),
  );
}

class TerminalViewerHome extends StatefulWidget {
  const TerminalViewerHome({super.key});

  @override
  State<TerminalViewerHome> createState() => _TerminalViewerHomeState();
}

class _TerminalViewerHomeState extends State<TerminalViewerHome> {
  RemVibeTerminal? _engine;
  TerminalSessionService? _service;
  HostedTerminalAttachment? _firstController;
  String? _firstSessionId;

  TerminalHandler? _firstHandler;
  TerminalHandler? _secondHandler;
  TerminalHandler? _mirrorHandler;

  Timer? _mockTicker;

  bool _mirrorFirst = false;
  bool _loading = true;
  int _firstGeneration = 0;
  String _message = 'Preparing viewer...';

  bool get _isWindows => Platform.isWindows;
  bool get _firstHasControl => _firstController?.isAttached ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initialize());
    });
  }

  Future<void> _initialize() async {
    try {
      if (_isWindows) {
        await _initializeNative();
      } else {
        _initializeMock();
      }
    } catch (error) {
      _message = 'Viewer initialization failed: $error';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _initializeNative() async {
    // Native Assets builds and loads the Windows ConPTY DLL.
    // No manually copied DLL or executable-relative lookup is required.
    final engine = RemVibeTerminal.windows();
    _engine = engine;
    final service = TerminalSessionService.withEngine(
      engine: engine,
      maximumSessions: 4,
      maximumReplayBytes: 64 * 1024,
    );
    _service = service;

    final first = service.newTerminal(
      commandLine: 'powershell.exe -NoLogo -NoProfile',
      columns: 90,
      rows: 28,
    );
    final second = service.newTerminal(
      commandLine: 'powershell.exe -NoLogo -NoProfile',
      columns: 90,
      rows: 28,
    );
    _firstController = first;
    _firstSessionId = first.sessionId;
    final a = service.findTerminal(first.sessionId)!;
    final b = service.findTerminal(second.sessionId)!;
    _firstHandler = TerminalHandlerLocal(terminal: a, controller: first);
    _secondHandler = TerminalHandlerLocal(terminal: b, controller: second);
    _mirrorHandler = TerminalHandlerLocal(terminal: a); // independent watcher
    _message = 'REAL Windows ConPTY: two independent PowerShell sessions';
  }

  void _initializeMock() {
    // Ubuntu/Linux verifies the cross-platform Flutter viewer only.
    // An actual Linux PTY backend has NOT been implemented in the core.
    final first = MockTerminalHandler('ubuntu-ui-mock-1');
    final second = MockTerminalHandler('ubuntu-ui-mock-2');
    _firstHandler = first;
    _secondHandler = second;
    _mirrorHandler = first;
    first.writeDemo('\x1b[36mUI MOCK / Ubuntu viewer test only\x1b[0m\r\n'
        'This is not a real terminal or Linux shell.\r\n');
    second.writeDemo('Independent second mock viewport\r\n');
    for (var i = 0; i < 110; i++) {
      first.writeDemo('Mock scrollback line ${i + 1}\r\n');
    }
    var tick = 0;
    _mockTicker = Timer.periodic(const Duration(seconds: 2), (_) {
      tick++;
      first.writeDemo('Viewer 1 live mock frame $tick\r\n');
      second.writeDemo('Viewer 2 live mock frame $tick\r\n');
    });
    _message = 'UBUNTU UI-ONLY TEST: mock source; Linux native PTY not supported';
  }

  Future<void> _toggleFirstControl() async {
    final service = _service;
    final id = _firstSessionId;
    if (service == null || id == null) return;
    try {
      if (_firstHasControl) {
        await _firstController!.detach(); // host-initiated, never widget-owned
        _firstController = null;
        _firstHandler =
            TerminalHandlerLocal(terminal: service.findTerminal(id)!);
        _message = 'Shell #1 controller detached; PTY still running';
      } else {
        final controller = service.attach(id);
        _firstController = controller;
        _firstHandler = TerminalHandlerLocal(
          terminal: service.findTerminal(id)!,
          controller: controller,
        );
        _message = 'Shell #1 controller reattached to same PTY';
      }
      if (mounted) {
        setState(() => _firstGeneration++);
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'Control action failed: $error');
    }
  }

  @override
  void dispose() {
    _mockTicker?.cancel();
    final service = _service;
    final engine = _engine;
    if (service != null) {
      unawaited(_closeNative(service, engine));
    } else if (engine != null) {
      unawaited(engine.close());
    }
    super.dispose();
  }

  Future<void> _closeNative(
    TerminalSessionService service,
    RemVibeTerminal? engine,
  ) async {
    await service.close();
    await engine?.close();
  }

  @override
  Widget build(BuildContext context) {
    final a = _firstHandler;
    final b = _mirrorFirst ? _mirrorHandler : _secondHandler;
    return Scaffold(
      appBar: AppBar(title: const Text('RemVibe Terminal Flutter · Two panes')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: (a == null || b == null)
                      ? null
                      : () => setState(() => _mirrorFirst = !_mirrorFirst),
                  child: Text(_mirrorFirst
                      ? 'Show two separate PTYs'
                      : 'Show two viewers of first PTY'),
                ),
                OutlinedButton(
                  onPressed: _isWindows && !_loading && a != null
                      ? () => unawaited(_toggleFirstControl())
                      : null,
                  child: Text(_firstHasControl
                      ? 'Detach first controller'
                      : 'Reattach first controller'),
                ),
                if (!_isWindows)
                  const Chip(label: Text('UI mock — no Linux shell')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(_message),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (a == null || b == null)
                    ? const Center(child: Text('No terminal viewers available'))
                    : Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: RemVibeTerminalWidget(
                                key: ValueKey('primary-$_firstGeneration'),
                                handler: a,
                                readOnly: _isWindows && !_firstHasControl,
                                label: _isWindows ? 'PowerShell #1' : 'Mock #1',
                                autofocus: true,
                                onError: (error) {
                                  if (mounted) {
                                    setState(() =>
                                        _message = 'First pane: $error');
                                  }
                                },
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: RemVibeTerminalWidget(
                                key: ValueKey(_mirrorFirst ? 'mirror' : 'second'),
                                handler: b,
                                readOnly: _mirrorFirst,
                                label: _mirrorFirst
                                    ? 'Same PTY • second viewer'
                                    : (_isWindows
                                        ? 'PowerShell #2'
                                        : 'Mock #2'),
                                autofocus: false,
                                onError: (error) {
                                  if (mounted) {
                                    setState(() =>
                                        _message = 'Second pane: $error');
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
