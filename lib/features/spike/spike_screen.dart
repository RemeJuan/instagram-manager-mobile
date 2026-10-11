import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kinship_mobile/probe/sqlite_probe.dart';

const int spikeMaxInputBytes = 50 * 1024 * 1024;

/// Only safe, user-facing messages belong here. Never include source paths,
/// filenames, usernames, or raw parser exceptions in messages.
class SpikeInputException implements Exception {
  const SpikeInputException(this.message);
  final String message;
}

/// Parsed, validated results supplied by the parser integration. Null means
/// unknown (for example, a missing or partial side), never zero.
class SpikeSummary {
  const SpikeSummary({
    this.following,
    this.followers,
    this.mutual,
    this.followingOnly,
    this.followerOnly,
    this.warnings = const [],
  });

  final int? following;
  final int? followers;
  final int? mutual;
  final int? followingOnly;
  final int? followerOnly;

  /// Warnings must be sanitized by the parser adapter before display.
  final List<String> warnings;
}

typedef SpikePicker = Future<XFile?> Function();
typedef SpikeParser = Future<SpikeSummary> Function(String workingPath);
typedef SpikeProbeRunner = Future<SqliteProbeResult> Function();

/// One-screen Phase 0 harness. Parser owns structural validation and runs
/// expensive work off the UI isolate; this screen only bounds and copies input.
class SpikeScreen extends StatefulWidget {
  const SpikeScreen({
    super.key,
    required this.parse,
    this.pickFile,
    this.temporaryDirectory,
    this.runProbe,
  });

  final SpikeParser parse;
  final SpikePicker? pickFile;
  final Future<Directory> Function()? temporaryDirectory;
  final SpikeProbeRunner? runProbe;

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  bool _busy = false;
  String _status = 'Ready to select a local export.';
  SpikeSummary? _summary;
  SqliteProbeResult? _probeResult;

  Future<void> _import() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _summary = null;
      _status = 'Opening file picker…';
    });
    Directory? workspace;
    try {
      final file = await (widget.pickFile ?? _defaultPicker)();
      if (file == null) {
        if (mounted) {
          setState(() => _status = 'Selection cancelled. No data imported.');
        }
        return;
      }
      if (mounted) setState(() => _status = 'Checking selected file size…');
      // File-provider metadata may be missing or wrong. Recheck every byte
      // while streaming into an app-owned workspace; never read all at once.
      final length = await file.length();
      if (length > spikeMaxInputBytes) {
        throw const SpikeInputException('File exceeds the 50 MiB input limit.');
      }
      final root = await (widget.temporaryDirectory ?? getTemporaryDirectory)();
      workspace = await root.createTemp('kinship-spike-');
      final copy = File('${workspace.path}/input');
      final sink = copy.openWrite();
      var bytes = 0;
      try {
        await for (final chunk in file.openRead()) {
          bytes += chunk.length;
          if (bytes > spikeMaxInputBytes) {
            throw const SpikeInputException(
              'File exceeds the 50 MiB input limit.',
            );
          }
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      if (mounted) setState(() => _status = 'Validating local export…');
      final summary = await widget.parse(copy.path);
      if (mounted) {
        setState(() {
          _summary = summary;
          _status = 'Import complete. Working copy removed.';
        });
      }
    } on SpikeInputException catch (error) {
      if (mounted) setState(() => _status = error.message);
    } on Object {
      // Source paths, provider errors, parser exceptions can contain private data.
      if (mounted) {
        setState(
          () => _status = 'Unable to import this file. No results were saved.',
        );
      }
    } finally {
      if (workspace != null) {
        try {
          await workspace.delete(recursive: true);
        } on FileSystemException {
          if (mounted) {
            setState(
              () => _status = 'Could not remove the temporary copy. Clear app temporary storage.',
            );
          }
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  static Future<XFile?> _defaultPicker() => openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'Instagram export ZIP or JSON',
        extensions: ['zip', 'json'],
      ),
    ],
  );

  Future<void> _probe() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _probeResult = null;
      _status = 'Checking local SQLite storage…';
    });
    try {
      final result = await (widget.runProbe ?? _runDisposableProbe)();
      if (mounted) {
        setState(() {
          _probeResult = result;
          _status = 'SQLite probe complete.';
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _status = 'SQLite probe failed. Check local storage.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static Future<SqliteProbeResult> _runDisposableProbe() async {
    final probe = await SqliteProbe.inApplicationDocuments();
    try {
      return await probe.run(
        sampleRows: const [
          ProbeObservation(
            id: 'synthetic-01',
            side: 'following',
            value: 'sample-a',
          ),
          ProbeObservation(
            id: 'synthetic-02',
            side: 'followers',
            value: 'sample-b',
          ),
        ],
      );
    } finally {
      await probe.deleteDatabase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final probe = _probeResult;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Kinship · Phase 0')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Local import test', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text(
              'Select an Instagram ZIP or JSON export. Data stays on this device. This test does not save relationship history.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose ZIP or JSON'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _probe,
              child: const Text('Run SQLite probe'),
            ),
            const SizedBox(height: 16),
            if (_busy)
              const LinearProgressIndicator(
                semanticsLabel: 'Operation in progress',
              ),
            Semantics(
              liveRegion: true,
              child: Text(_status, key: const Key('spike-status')),
            ),
            if (summary != null) ...[
              const SizedBox(height: 24),
              Text('Relationship counts', style: theme.textTheme.titleLarge),
              _count('Following', summary.following),
              _count('Followers', summary.followers),
              _count('Mutual', summary.mutual),
              _count('Following only', summary.followingOnly),
              _count('Follower only', summary.followerOnly),
              for (final warning in summary.warnings)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Warning: $warning'),
                ),
            ],
            if (probe != null) ...[
              const SizedBox(height: 24),
              Text('SQLite checks', style: theme.textTheme.titleLarge),
              _check('Initial write and read', probe.initialRows.length == 2),
              _check(
                'Close and reopen',
                _sameRows(probe.initialRows, probe.reopenedRows),
              ),
              _check('Invalid write rolled back', probe.rollbackPreservedRows),
              _check('Future schema rejected', probe.futureSchemaRejected),
            ],
            const SizedBox(height: 24),
            const Text(
              'Exports are snapshots. Missing or partial sides cannot establish absence. Export and import timestamps are not follow or unfollow event times. An export cannot prove a rename, deletion, or block.',
            ),
          ],
        ),
      ),
    );
  }

  static bool _sameRows(List<ProbeObservation> a, List<ProbeObservation> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((equal) => equal);

  Widget _count(String label, int? value) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(
      value?.toString() ?? 'Unknown',
      semanticsLabel: '$label: ${value ?? 'unknown'}',
    ),
  );

  Widget _check(String label, bool passed) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    trailing: Text(
      passed ? 'Pass' : 'Fail',
      semanticsLabel: '$label: ${passed ? 'pass' : 'fail'}',
    ),
  );
}
