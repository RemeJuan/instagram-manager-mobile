import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

class ValidatedZipException implements Exception {
  const ValidatedZipException(this.code);
  final String code;
  @override
  String toString() => 'ValidatedZipException($code)';
}

class StagedZipEntry {
  const StagedZipEntry(this.name, this.file, this.expandedBytes);
  final String name;
  final File file;
  final int expandedBytes;
}

const int validatedZipCompressedLimit = 50 * 1024 * 1024;
const int validatedZipExpandedLimit = 200 * 1024 * 1024;
const int validatedZipEntryLimit = 20 * 1024 * 1024;
const int validatedZipEntryCountLimit = 500;
const int _compressedLimit = validatedZipCompressedLimit;
const int _expandedLimit = validatedZipExpandedLimit;
const int _entryLimit = validatedZipEntryLimit;
const int _chunk = 32 * 1024;

Future<T> withValidatedZipEntries<T>(
  File source,
  Directory stagingDirectory,
  Future<T> Function(List<StagedZipEntry>) process, {
  int maxExpandedBytes = _expandedLimit,
  int maxEntryCount = validatedZipEntryCountLimit,
  void Function(int count)? onEntryCount,
}) async {
  Directory? work;
  RandomAccessFile? input;
  Object? primaryError;
  StackTrace? primaryStack;
  try {
    if (await source.length() > _compressedLimit) _fail('compressed_limit');
    await stagingDirectory.create(recursive: true);
    work = await stagingDirectory.createTemp('validated_zip_');
    input = await source.open(mode: FileMode.read);
    final length = await input.length();
    if (length > _compressedLimit) _fail('compressed_limit');
    if (length < 22) _fail('invalid_archive');
    final eocdOffset = await _findEocd(input, length);
    final directory = await _readDirectory(input, eocdOffset);
    final effectiveExpandedLimit = math.min(maxExpandedBytes, _expandedLimit);
    final effectiveEntryCount = math.min(
      maxEntryCount,
      validatedZipEntryCountLimit,
    );
    if (directory.entries.length > effectiveEntryCount) {
      _fail('entry_count_limit');
    }
    onEntryCount?.call(directory.entries.length);
    final ranges = <_Range>[];
    var compressed = 0, declared = 0;
    for (final entry in directory.entries) {
      compressed += entry.compressed;
      declared += entry.expanded;
      if (compressed > _compressedLimit || declared > effectiveExpandedLimit) {
        _fail('size_limit');
      }
      if (entry.expanded > _entryLimit) _fail('entry_size_limit');
      if (entry.compressed == 0
          ? entry.expanded != 0
          : entry.expanded > entry.compressed * 200) {
        _fail('ratio_limit');
      }
      final range = await _localRange(input, eocdOffset, entry);
      entry.dataOffset = range.data;
      for (final old in ranges) {
        if (range.start < old.end && old.start < range.end) _fail('overlap');
      }
      ranges.add(range);
    }
    ranges.sort((a, b) => a.start.compareTo(b.start));
    var cursor = 0;
    for (final range in ranges) {
      if (range.start != cursor) _fail('ambiguous_layout');
      cursor = range.end;
    }
    if (cursor != directory.offset) _fail('ambiguous_layout');

    final staged = <StagedZipEntry>[];
    var aggregate = 0, index = 0;
    for (final entry in directory.entries) {
      if (entry.directory) continue;
      final output = File('${work.path}/entry_${index++}.json');
      final raf = await output.open(mode: FileMode.write);
      final remaining = effectiveExpandedLimit - aggregate;
      final sink = _BoundedOutput(
        raf,
        entry.expanded,
        entry.compressed,
        remaining,
      );
      try {
        if (entry.method == 0) {
          await _copyStored(input, entry.dataOffset, entry.compressed, sink);
        } else if (entry.method == 8) {
          await _copyDeflated(input, entry.dataOffset, entry.compressed, sink);
        } else {
          _fail('unsupported_compression');
        }
        sink.check(entry.crc);
      } finally {
        await raf.close();
      }
      aggregate += sink.count;
      if (aggregate > effectiveExpandedLimit) _fail('size_limit');
      if (_isZip(output)) _fail('nested_archive');
      staged.add(StagedZipEntry(entry.name, output, sink.count));
    }
    return await process(List.unmodifiable(staged));
  } catch (error, stack) {
    if (error is ValidatedZipException) {
      primaryError = error;
      primaryStack = stack;
    } else if (work != null && error is FileSystemException) {
      primaryError = const ValidatedZipException('io_failure');
      primaryStack = stack;
    } else {
      primaryError = error;
      primaryStack = stack;
    }
  } finally {
    try {
      await input?.close();
    } catch (_) {
      primaryError ??= const ValidatedZipException('cleanup_failed');
    }
    try {
      if (work != null && await work.exists()) {
        await work.delete(recursive: true);
      }
      if (work != null && await work.exists()) {
        primaryError ??= const ValidatedZipException('cleanup_failed');
      }
    } catch (_) {
      primaryError ??= const ValidatedZipException('cleanup_failed');
    }
    if (primaryError != null) {
      Error.throwWithStackTrace(
        primaryError,
        primaryStack ?? StackTrace.current,
      );
    }
  }
  throw const ValidatedZipException('invalid_archive');
}

Never _fail(String code) => throw ValidatedZipException(code);

Future<int> _findEocd(RandomAccessFile file, int length) async {
  final start = math.max(0, length - 65557);
  await file.setPosition(start);
  final tail = await file.read(length - start);
  for (var i = tail.length - 22; i >= 0; i--) {
    if (_u32(tail, i) == 0x06054b50 &&
        i + 22 + _u16(tail, i + 20) == tail.length) {
      return start + i;
    }
  }
  _fail('invalid_archive');
}

Future<_Directory> _readDirectory(RandomAccessFile file, int eocd) async {
  final h = await _readAt(file, eocd, 22);
  if (_u16(h, 4) != 0 || _u16(h, 6) != 0 || _u16(h, 8) != _u16(h, 10)) {
    _fail('unsupported_archive');
  }
  final count = _u16(h, 10), size = _u32(h, 12), offset = _u32(h, 16);
  if (count > validatedZipEntryCountLimit ||
      size == 0xffffffff ||
      offset == 0xffffffff ||
      offset + size != eocd) {
    _fail('invalid_directory');
  }
  final entries = <_Entry>[];
  final names = <String>{};
  var pos = offset;
  for (var i = 0; i < count; i++) {
    final h = await _readAt(file, pos, 46);
    if (_u32(h, 0) != 0x02014b50) _fail('invalid_directory');
    final nl = _u16(h, 28), xl = _u16(h, 30), cl = _u16(h, 32);
    if (nl == 0 || nl > 4096 || xl > 16384 || cl > 16384) {
      _fail('metadata_limit');
    }
    final nb = await _readAt(file, pos + 46, nl);
    final flags = _u16(h, 8), name = _decodeName(nb, flags);
    _validateName(name);
    if (!names.add(name.toLowerCase())) _fail('duplicate_name');
    final method = _u16(h, 10), csize = _u32(h, 20), usize = _u32(h, 24);
    if ((flags & ~(0x0800 | 0x0008)) != 0 ||
        flags & 1 != 0 ||
        (method != 0 && method != 8) ||
        csize == 0xffffffff ||
        usize == 0xffffffff ||
        _u16(h, 6) < 10 ||
        _u16(h, 6) > 63) {
      _fail('unsupported_entry');
    }
    final attr = _u32(h, 38);
    if (attr & 0x0000ffff != 0) _fail('unsupported_attributes');
    final mode = (attr >> 16) & 0xffff, type = mode & 0xf000;
    final isDir = name.endsWith('/');
    if ((type != 0 && type != 0x8000 && type != 0x4000) ||
        (type != 0 && isDir != (type == 0x4000)) ||
        (isDir && (csize != 0 || usize != 0 || _u32(h, 16) != 0))) {
      _fail('unsupported_attributes');
    }
    entries.add(
      _Entry(
        name,
        nb,
        flags,
        method,
        _u32(h, 42),
        _u32(h, 16),
        csize,
        usize,
        isDir,
      ),
    );
    pos += 46 + nl + xl + cl;
  }
  if (pos != offset + size) _fail('invalid_directory');
  return _Directory(entries, offset);
}

Future<_Range> _localRange(
  RandomAccessFile f,
  int centralOffset,
  _Entry e,
) async {
  final h = await _readAt(f, e.localOffset, 30);
  if (_u32(h, 0) != 0x04034b50) _fail('invalid_local_header');
  final nl = _u16(h, 26), xl = _u16(h, 28);
  if (nl != e.nameBytes.length || xl > 16384) _fail('invalid_local_header');
  final nb = await _readAt(f, e.localOffset + 30, nl);
  final descriptor = (e.flags & 8) != 0;
  if (!_same(nb, e.nameBytes) ||
      _u16(h, 6) != e.flags ||
      _u16(h, 8) != e.method ||
      (!descriptor &&
          (_u32(h, 14) != e.crc ||
              _u32(h, 18) != e.compressed ||
              _u32(h, 22) != e.expanded)) ||
      (descriptor &&
          (_u32(h, 14) != 0 && _u32(h, 14) != e.crc ||
              _u32(h, 18) != 0 && _u32(h, 18) != e.compressed ||
              _u32(h, 22) != 0 && _u32(h, 22) != e.expanded))) {
    _fail('metadata_mismatch');
  }
  final end = e.localOffset + 30 + nl + xl + e.compressed;
  if (end > centralOffset || e.localOffset >= centralOffset) {
    _fail('truncated_entry');
  }
  var rangeEnd = end;
  if (descriptor) {
    final descriptorAt = end;
    final first = await _readAt(f, descriptorAt, 4);
    final hasSignature = _u32(first, 0) == 0x08074b50;
    final descriptorBytes = await _readAt(
      f,
      descriptorAt + (hasSignature ? 4 : 0),
      12,
    );
    if (_u32(descriptorBytes, 0) != e.crc ||
        _u32(descriptorBytes, 4) != e.compressed ||
        _u32(descriptorBytes, 8) != e.expanded) {
      _fail('metadata_mismatch');
    }
    rangeEnd += (hasSignature ? 16 : 12);
  }
  if (rangeEnd > centralOffset) _fail('truncated_entry');
  return _Range(e.localOffset, rangeEnd, e.localOffset + 30 + nl + xl);
}

String _decodeName(List<int> b, int flags) {
  if ((flags & 0x0800) == 0) _fail('unsafe_name');
  try {
    final name = utf8.decode(b, allowMalformed: false);
    if (name.codeUnits.any((c) => c < 32 || c == 127)) {
      _fail('unsafe_name');
    }
    return name;
  } catch (_) {
    _fail('unsafe_name');
  }
}

void _validateName(String name) {
  if (name.startsWith('/') ||
      name.contains('\\') ||
      RegExp(r'^[A-Za-z]:').hasMatch(name)) {
    _fail('unsafe_name');
  }
  final parts = name.split('/');
  final checked = name.endsWith('/')
      ? parts.sublist(0, parts.length - 1)
      : parts;
  if (checked.isEmpty ||
      checked.any((part) => part.isEmpty || part == '.' || part == '..')) {
    _fail('unsafe_name');
  }
}

Future<List<int>> _readAt(RandomAccessFile f, int pos, int count) async {
  await f.setPosition(pos);
  final b = await f.read(count);
  if (b.length != count) _fail('truncated_archive');
  return b;
}

Future<void> _copyStored(
  RandomAccessFile f,
  int pos,
  int size,
  _BoundedOutput out,
) async {
  await f.setPosition(pos);
  var remain = size;
  while (remain > 0) {
    final b = await f.read(math.min(_chunk, remain));
    if (b.isEmpty) _fail('truncated_entry');
    out.add(b);
    remain -= b.length;
  }
}

Future<void> _copyDeflated(
  RandomAccessFile f,
  int pos,
  int size,
  _BoundedOutput out,
) async {
  await f.setPosition(pos);
  final controller = ZLibDecoder(raw: true)
      .startChunkedConversion(_ZipOutputSink(out));
  var remain = size;
  while (remain > 0) {
    final bytes = await f.read(math.min(_chunk, remain));
    if (bytes.isEmpty) _fail('truncated_entry');
    try {
      controller.add(bytes);
    } on FormatException {
      _fail('invalid_deflate');
    }
    remain -= bytes.length;
  }
  try {
    controller.close();
  } on FormatException {
    _fail('invalid_deflate');
  }
}

class _ZipOutputSink implements Sink<List<int>> {
  _ZipOutputSink(this.output);
  final _BoundedOutput output;
  @override
  void add(List<int> data) => output.add(data);
  @override
  void close() {}
}

class _BoundedOutput {
  _BoundedOutput(
    this.file,
    this.expected,
    this.compressed,
    this.aggregateRemaining,
  );
  final RandomAccessFile file;
  final int expected, compressed, aggregateRemaining;
  int count = 0, crc = 0xffffffff;
  void add(List<int> bytes) {
    count += bytes.length;
    if (count > expected ||
        count > _entryLimit ||
        count > _expandedLimit ||
        count > aggregateRemaining ||
        (compressed == 0 ? count > 0 : count > compressed * 200)) {
      _fail('expanded_limit');
    }
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
      }
    }
    file.writeFromSync(bytes);
  }

  void check(int expectedCrc) {
    if (count != expected || (crc ^ 0xffffffff) & 0xffffffff != expectedCrc) {
      _fail('integrity_mismatch');
    }
  }
}

bool _isZip(File file) {
  final raf = file.openSync();
  try {
    if (raf.lengthSync() < 4) return false;
    final b = raf.readSync(4);
    return _u32(b, 0) == 0x04034b50 ||
        _u32(b, 0) == 0x06054b50 ||
        _u32(b, 0) == 0x08074b50;
  } finally {
    raf.closeSync();
  }
}

int _u16(List<int> b, int i) => b[i] | (b[i + 1] << 8);
int _u32(List<int> b, int i) => _u16(b, i) | (_u16(b, i + 2) << 16);
bool _same(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _Directory {
  _Directory(this.entries, this.offset);
  final List<_Entry> entries;
  final int offset;
}

class _Entry {
  _Entry(
    this.name,
    this.nameBytes,
    this.flags,
    this.method,
    this.localOffset,
    this.crc,
    this.compressed,
    this.expanded,
    this.directory,
  );
  final String name;
  final List<int> nameBytes;
  final int flags, method, localOffset, crc, compressed, expanded;
  final bool directory;
  int dataOffset = 0;
}

class _Range {
  _Range(this.start, this.end, this.data);
  final int start, end, data;
}
