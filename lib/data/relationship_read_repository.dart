import 'package:drift/drift.dart';

import '../domain/relationship.dart';
import 'app_database.dart';

enum RelationshipCategory { mutual, followingOnly, followerOnly, unknown }

final class RelationshipRow {
  const RelationshipRow({
    required this.username,
    required this.category,
    required this.followersCoverage,
    required this.followingCoverage,
    required this.followersCoverageImportId,
    required this.followingCoverageImportId,
    required this.followersAbsenceImportId,
    required this.followingAbsenceImportId,
  });

  final String username;
  final RelationshipCategory category;
  final Coverage followersCoverage;
  final Coverage followingCoverage;
  final int? followersCoverageImportId;
  final int? followingCoverageImportId;
  final int? followersAbsenceImportId;
  final int? followingAbsenceImportId;
}

final class RelationshipPage {
  const RelationshipPage({required this.totalCount, required this.rows});
  final int totalCount;
  final List<RelationshipRow> rows;
}

final class RelationshipCounts {
  const RelationshipCounts({
    required this.mutual,
    required this.followingOnly,
    required this.followerOnly,
    required this.unknown,
  });

  final int mutual;
  final int followingOnly;
  final int followerOnly;
  final int unknown;
}

/// Stable canonical ordering; search is a literal, case-insensitive substring.
final class RelationshipReadRepository {
  const RelationshipReadRepository(this.db);
  final AppDatabase db;

  static const _followers = 'followers';
  static const _following = 'following';

  String get _categoryExpression =>
      '''CASE
    WHEN EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_followers' AND x.status='present')
     AND EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_following' AND x.status='present') THEN 'mutual'
    WHEN EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_following' AND x.status='present')
     AND EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_followers' AND x.status='absent') THEN 'followingOnly'
    WHEN EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_followers' AND x.status='present')
     AND EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_following' AND x.status='absent') THEN 'followerOnly'
    WHEN EXISTS(SELECT 1 FROM relationship_states x WHERE x.account_id=a.id AND x.status='present') THEN 'unknown'
    ELSE NULL END''';

  Future<RelationshipPage> page({
    String? search,
    RelationshipCategory? category,
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 500 || offset < 0) {
      throw ArgumentError('Invalid page bounds');
    }
    return db.transaction(() async {
      final (where, vars) = _filters(search, category);
      final count = await db
          .customSelect(
            'SELECT COUNT(*) AS n FROM observed_accounts a $where',
            variables: vars,
          )
          .getSingle();
      final rows = await db
          .customSelect(
            '''
        SELECT a.canonical_username AS username, ($_categoryExpression) AS category,
          (SELECT s.coverage FROM import_sides s WHERE s.side='$_followers' ORDER BY s.import_id DESC LIMIT 1) AS fc,
          (SELECT s.import_id FROM import_sides s WHERE s.side='$_followers' ORDER BY s.import_id DESC LIMIT 1) AS fci,
          (SELECT s.coverage FROM import_sides s WHERE s.side='$_following' ORDER BY s.import_id DESC LIMIT 1) AS gc,
          (SELECT s.import_id FROM import_sides s WHERE s.side='$_following' ORDER BY s.import_id DESC LIMIT 1) AS gci,
          (SELECT x.latest_complete_absence_import_id FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_followers') AS fai,
          (SELECT x.latest_complete_absence_import_id FROM relationship_states x WHERE x.account_id=a.id AND x.side='$_following') AS gai
        FROM observed_accounts a $where
        ORDER BY a.canonical_username, a.id LIMIT ? OFFSET ?
      ''',
            variables: [
              ...vars,
              Variable.withInt(limit),
              Variable.withInt(offset),
            ],
          )
          .get();
      Coverage cov(Object? value) => value == 'complete'
          ? Coverage.complete
          : value == 'partial'
          ? Coverage.partial
          : Coverage.missing;
      return RelationshipPage(
        totalCount: count.read<int>('n'),
        rows: List.unmodifiable(
          rows.map(
            (row) => RelationshipRow(
              username: row.read<String>('username'),
              category: RelationshipCategory.values.byName(
                row.read<String>('category'),
              ),
              followersCoverage: cov(row.data['fc']),
              followingCoverage: cov(row.data['gc']),
              followersCoverageImportId: row.data['fci'] as int?,
              followingCoverageImportId: row.data['gci'] as int?,
              followersAbsenceImportId: row.data['fai'] as int?,
              followingAbsenceImportId: row.data['gai'] as int?,
            ),
          ),
        ),
      );
    });
  }

  Future<RelationshipCounts> counts({String? search}) async {
    final (where, vars) = _filters(search, null);
    final row = await db.customSelect('''
      SELECT
        SUM(CASE WHEN c='mutual' THEN 1 ELSE 0 END) AS mutual,
        SUM(CASE WHEN c='followingOnly' THEN 1 ELSE 0 END) AS following_only,
        SUM(CASE WHEN c='followerOnly' THEN 1 ELSE 0 END) AS follower_only,
        SUM(CASE WHEN c='unknown' THEN 1 ELSE 0 END) AS unknown
      FROM (SELECT ($_categoryExpression) AS c FROM observed_accounts a $where)
    ''', variables: vars).getSingle();
    return RelationshipCounts(
      mutual: row.read<int?>('mutual') ?? 0,
      followingOnly: row.read<int?>('following_only') ?? 0,
      followerOnly: row.read<int?>('follower_only') ?? 0,
      unknown: row.read<int?>('unknown') ?? 0,
    );
  }

  (String, List<Variable<Object>>) _filters(
    String? search,
    RelationshipCategory? category,
  ) {
    final clauses = <String>[];
    final vars = <Variable<Object>>[];
    if (search != null && search.isNotEmpty) {
      clauses.add('instr(lower(a.canonical_username), lower(?)) > 0');
      vars.add(Variable.withString(search));
    }
    if (category != null) {
      clauses.add('($_categoryExpression) = ?');
      vars.add(Variable.withString(category.name));
    } else {
      clauses.add('($_categoryExpression) IS NOT NULL');
    }
    return (clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}', vars);
  }
}
