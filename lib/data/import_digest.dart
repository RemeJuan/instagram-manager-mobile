import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../domain/relationship.dart';

/// Digests snapshot content, including coverage and retained row metadata.
String digestImport(
  RelationshipSnapshot snapshot, {
  required String parserVersion,
}) => _digest((encoder) {
  encoder.string('kinship-import-digest-v1');
  encoder.string(parserVersion);
  for (final side in RelationshipSide.values) {
    _encodeSide(encoder, snapshot, side);
  }
});

/// Digests each present side independently. Missing sides are omitted.
Map<RelationshipSide, String> digestPresentSides(
  RelationshipSnapshot snapshot, {
  required String parserVersion,
}) {
  final result = <RelationshipSide, String>{};
  for (final side in RelationshipSide.values) {
    if (_coverage(snapshot, side) == Coverage.missing) continue;
    result[side] = _digest((encoder) {
      encoder.string('kinship-import-side-digest-v1');
      encoder.string(parserVersion);
      _encodeSide(encoder, snapshot, side);
    });
  }
  return Map.unmodifiable(result);
}

String _digest(void Function(_Encoder) encode) {
  final encoder = _Encoder();
  encode(encoder);
  return sha256.convert(encoder.bytes).toString();
}

void _encodeSide(
  _Encoder encoder,
  RelationshipSnapshot snapshot,
  RelationshipSide side,
) {
  encoder.string(side.name);
  encoder.string(_coverage(snapshot, side).name);
  final observations =
      switch (side) {
          RelationshipSide.following => snapshot.following.values,
          RelationshipSide.followers => snapshot.followers.values,
        }.toList()
        ..sort((a, b) => a.identity.canonical.compareTo(b.identity.canonical));
  encoder.integer(observations.length);
  for (final observation in observations) {
    encoder.string(observation.identity.canonical);
    encoder.string(observation.identity.display);
    encoder.nullableInteger(observation.sourceTimestamp);
    encoder.string(observation.sourceTimestamp == null ? '' : 'export_row');
  }
}

Coverage _coverage(RelationshipSnapshot snapshot, RelationshipSide side) =>
    switch (side) {
      RelationshipSide.following => snapshot.followingCoverage,
      RelationshipSide.followers => snapshot.followersCoverage,
    };

/// Network-order, length-delimited encoding prevents field-boundary ambiguity.
final class _Encoder {
  final BytesBuilder _builder = BytesBuilder(copy: false);

  List<int> get bytes => _builder.takeBytes();

  void string(String value) {
    final encoded = utf8.encode(value);
    integer(encoded.length);
    _builder.add(encoded);
  }

  void integer(int value) {
    final data = ByteData(8)..setUint64(0, value, Endian.big);
    _builder.add(data.buffer.asUint8List());
  }

  void nullableInteger(int? value) {
    _builder.addByte(value == null ? 0 : 1);
    if (value != null) {
      final data = ByteData(8)..setInt64(0, value, Endian.big);
      _builder.add(data.buffer.asUint8List());
    }
  }
}
