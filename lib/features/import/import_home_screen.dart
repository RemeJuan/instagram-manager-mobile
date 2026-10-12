import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/data/import_review_repository.dart';
import 'package:kinship_mobile/data/relationship_read_repository.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/features/import/import_workspace.dart';
import 'package:kinship_mobile/import/import_preview.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:kinship_mobile/features/pro/pro_screen.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:kinship_mobile/purchases/capability_policy.dart';

const _pageSize = 30;
const _ink = KinshipColors.ink;

/// Local Stage 4 surface. Does not own storage, file access or URL launching.
class ImportHomeScreen extends StatefulWidget {
  const ImportHomeScreen({
    super.key,
    required this.workspace,
    required this.review,
    required this.read,
    required this.openProfile,
    this.purchaseGateway,
    this.paywallPresenter,
  });

  final ImportWorkspace workspace;
  final ImportReviewRepository review;
  final RelationshipReadRepository read;
  final Future<bool> Function(Uri) openProfile;
  final PurchaseGateway? purchaseGateway;
  final ProPaywallPresenter? paywallPresenter;

  @override
  State<ImportHomeScreen> createState() => _ImportHomeScreenState();
}

class _ImportHomeScreenState extends State<ImportHomeScreen> {
  AppLocalizations get l => AppLocalizations.of(context)!;
  ParsedImport? _preview;
  final _choices = <RelationshipSide, Coverage>{};
  final _acknowledged = <RelationshipSide>{};
  final _proposals = <RelationshipSide, AbsenceReviewProposal>{};
  final _counts = <RelationshipCategory, int?>{};
  final _rows = <RelationshipRow>[];
  final _search = TextEditingController();
  RelationshipCategory? _category;
  int? _revision;
  int _total = 0;
  int _offset = 0;
  int _queryVersion = 0;
  int _entitlementVersion = 0;
  PurchaseSnapshot _entitlement = const PurchaseSnapshot(
    EntitlementState.unknown,
  );
  StreamSubscription<PurchaseSnapshot>? _purchaseUpdates;
  int _tab = 0;
  bool _busy = false;
  bool _loadingRows = false;
  bool _reviewReady = false;
  bool _detailsVisible = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _category = RelationshipCategory.mutual;
    final gateway = widget.purchaseGateway;
    if (gateway != null) {
      _purchaseUpdates = gateway.updates.listen(_applyEntitlement);
      _refreshEntitlement();
    }
    _reloadDashboard();
  }

  CapabilityPolicy get _capabilities => CapabilityPolicy(_entitlement);
  bool get _fullLists => _capabilities.canViewCompleteLists;

  void _applyEntitlement(PurchaseSnapshot snapshot) {
    if (!mounted) return;
    _entitlementVersion++;
    if (!snapshot.isPro && _detailsVisible) {
      _detailsVisible = false;
      Navigator.of(context).pop();
    }
    final previous = _fullLists;
    setState(() {
      _entitlement = snapshot;
      if (!snapshot.isPro) {
        _category ??= RelationshipCategory.mutual;
        _search.clear();
        _offset = 0;
        _rows.clear();
        _total = 0;
      } else if (!previous) {
        _category = null;
      }
    });
    _reloadDashboard();
  }

  Future<void> _refreshEntitlement() async {
    final gateway = widget.purchaseGateway;
    if (gateway == null) return;
    final version = _entitlementVersion;
    try {
      final snapshot = await gateway.customerInfo();
      if (mounted && version == _entitlementVersion) {
        _applyEntitlement(snapshot);
      }
    } on Object {
      if (mounted && version == _entitlementVersion) {
        _applyEntitlement(const PurchaseSnapshot(EntitlementState.unknown));
      }
    }
  }

  @override
  void dispose() {
    _queryVersion++;
    _purchaseUpdates?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
      _preview = null;
      _reviewReady = false;
      _proposals.clear();
      _choices.clear();
      _acknowledged.clear();
    });
    try {
      final parsed = await widget.workspace.pickAndParse();
      if (!mounted || parsed == null) return; // Cancellation needs no warning.
      setState(() {
        _preview = parsed;
        for (final side in parsed.sides.keys) {
          _choices[side] = Coverage.partial;
        }
      });
    } on ImportWorkspaceException catch (error) {
      if (mounted) setState(() => _notice = _inputMessage(error.code));
    } on ImportException catch (error) {
      if (mounted) setState(() => _notice = _inputMessage(error.code));
    } on Object {
      if (mounted) {
        setState(() => _notice = l.readExportFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _inputMessage(String code) => switch (code) {
    'input_size_exceeded' ||
    'compressed_limit_exceeded' ||
    'input_limit_exceeded' => l.exportTooLarge,
    'file_count_exceeded' ||
    'row_limit_exceeded' ||
    'expanded_limit_exceeded' => l.exportSafetyLimit,
    'no_relationship_data' => l.noRelationshipData,
    'cleanup_failed' => l.tempCleanupFailed,
    _ => l.exportValidationFailed,
  };

  void _choose(RelationshipSide side, Coverage coverage) {
    setState(() {
      if (_choices[side] != coverage) _acknowledged.remove(side);
      _choices[side] = coverage;
      _reviewReady = false;
      _proposals.clear();
      _notice = null;
    });
  }

  Future<void> _reviewImport() async {
    final preview = _preview;
    if (_busy || preview == null || !_allAcknowledged) return;
    setState(() {
      _busy = true;
      _reviewReady = false;
      _proposals.clear();
      _notice = null;
    });
    try {
      final review = await widget.review.review(
        preview: preview,
        choices: Map.of(_choices),
        sides: _choices.entries
            .where((entry) => entry.value == Coverage.complete)
            .map((entry) => entry.key)
            .toSet(),
        sampleLimit: CapabilityPolicy.freeSampleLimit,
      );
      if (!mounted || _preview != preview) return;
      setState(() {
        _revision = review.expectedLatestImportId;
        _proposals.addAll(review.proposals);
        _reviewReady = true;
      });
    } on Object {
      if (mounted) {
        setState(() => _notice = l.prepareReviewFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final preview = _preview;
    if (_busy || !_reviewReady || preview == null || !_allAcknowledged) return;
    setState(() {
      _busy = true;
      _reviewReady = false;
    });
    try {
      final outcome = await widget.review.commit(
        preview: preview,
        choices: Map.of(_choices),
        expectedLatestImportId: _revision,
      );
      if (!mounted) return;
      switch (outcome.status) {
        case CommitStatus.committed:
          setState(() {
            _preview = null;
            _notice = l.importSaved;
          });
          await _reloadDashboard();
        case CommitStatus.replay:
          setState(() {
            _preview = null;
            _notice = l.importAlreadySaved;
          });
          await _reloadDashboard();
        case CommitStatus.stale:
          setState(() {
            _proposals.clear();
            _notice = l.savedDataChanged;
          });
          _revision = null;
        case CommitStatus.rejected:
          setState(() => _notice = l.importRejected);
      }
    } on Object {
      if (mounted) {
        setState(() => _notice = l.importSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool get _allAcknowledged =>
      _preview != null && _preview!.sides.keys.every(_acknowledged.contains);

  Future<void> _reloadDashboard() async {
    _offset = 0;
    await _loadPage(refreshCounts: true);
  }

  Future<void> _loadPage({required bool refreshCounts}) async {
    if (!mounted) return;
    final full = _fullLists;
    final version = ++_queryVersion;
    setState(() {
      _loadingRows = true;
      _rows.clear();
    });
    try {
      RelationshipCounts? counts;
      if (refreshCounts) {
        counts = await widget.read.counts(
          search: full ? _search.text.trim() : '',
        );
      }
      final page = await widget.read.page(
        category: full ? _category : (_category ?? RelationshipCategory.mutual),
        search: full ? _search.text.trim() : '',
        limit: full ? _pageSize : CapabilityPolicy.freeSampleLimit,
        offset: full ? _offset : 0,
      );
      if (!mounted || version != _queryVersion || full != _fullLists) return;
      setState(() {
        if (counts != null) {
          _counts
            ..clear()
            ..addAll({
              RelationshipCategory.mutual: counts.mutual,
              RelationshipCategory.followingOnly: counts.followingOnly,
              RelationshipCategory.followerOnly: counts.followerOnly,
              RelationshipCategory.unknown: counts.unknown,
            });
        }
        _rows.addAll(
          page.rows.take(full ? _pageSize : CapabilityPolicy.freeSampleLimit),
        );
        _total = page.totalCount;
      });
    } on Object {
      if (mounted && version == _queryVersion) {
        setState(() {
          _offset = 0;
          _total = 0;
          _notice = l.savedResultsUnavailable;
        });
      }
    } finally {
      if (mounted && version == _queryVersion) {
        setState(() => _loadingRows = false);
      }
    }
  }

  void _changePage(int offset) {
    if (!_fullLists) return;
    if (_loadingRows || offset < 0 || offset >= _total) return;
    _offset = offset;
    _loadPage(refreshCounts: false);
  }

  void _filter(RelationshipCategory? category) {
    if (!_fullLists && category == null) return;
    setState(() => _category = category);
    _reloadDashboard();
  }

  Future<void> _copy(String username) async {
    await Clipboard.setData(ClipboardData(text: username));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.usernameCopied)));
    }
  }

  Future<void> _open(String username) async {
    // Rows come from canonical persisted identities, not an untrusted URL.
    final identity = UsernameIdentity.tryParse(username);
    if (identity == null || identity.canonical != username) return;
    try {
      final opened = await widget.openProfile(
        Uri.https('www.instagram.com', '/$username/'),
      );
      if (mounted && !opened) {
        setState(() => _notice = l.openProfileFailed);
      }
    } on Object {
      if (mounted) setState(() => _notice = l.openProfileFailed);
    }
  }

  Future<void> _openInfoLink(Uri uri) async {
    try {
      final opened = await widget.openProfile(uri);
      if (mounted && !opened) {
        setState(() => _notice = l.openInfoLinkFailed);
      }
    } on Object {
      if (mounted) setState(() => _notice = l.openInfoLinkFailed);
    }
  }

  Future<void> _openPro() async {
    final gateway = widget.purchaseGateway;
    if (gateway == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProScreen(
          gateway: gateway,
          presenter:
              widget.paywallPresenter ?? const RevenueCatPaywallPresenter(),
        ),
      ),
    );
    if (mounted) await _refreshEntitlement();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final preview = _preview;
    final hasSavedAccounts = _counts.values.whereType<int>().any((n) => n > 0);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(
              child: Image(
                image: AssetImage('assets/icons/kinship_logo.png'),
                width: 28,
                height: 28,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.appName,
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          if (widget.purchaseGateway != null)
            IconButton(
              key: const Key('open-pro'),
              tooltip: l.proTitle,
              onPressed: _openPro,
              icon: const Icon(Icons.auto_awesome_outlined),
            ),
          if (MediaQuery.sizeOf(context).width >= 390)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  l.privateByDesign,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: KinshipColors.muted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: [
          NavigationDestination(
            key: Key('nav-home'),
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          NavigationDestination(
            key: Key('nav-accounts'),
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l.navAccounts,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              key: ValueKey('view-$_tab'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                if (_tab == 0) ...[
                  Text(
                    l.homeHeadline,
                    style: hasSavedAccounts
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (!hasSavedAccounts) ...[
                    const SizedBox(height: 10),
                    Text(
                      l.homeIntro,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  SizedBox(height: hasSavedAccounts ? 14 : 24),
                  _heroCard(preview, compact: hasSavedAccounts),
                  const SizedBox(height: 12),
                  _infoLinks(),
                ] else ...[
                  Text(
                    l.savedAccounts,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.savedAccountsIntro,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _infoLinks(),
                  if (!_fullLists && widget.purchaseGateway != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      key: const Key('sample-upgrade'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: KinshipColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.sampleHeading,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _entitlement.state == EntitlementState.unknown
                                ? l.sampleUnknown
                                : l.sampleDescription,
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            key: const Key('sample-open-pro'),
                            onPressed: _openPro,
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: Text(l.sampleUnlock),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                if (_busy || _loadingRows) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(semanticsLabel: l.working),
                ],
                if (_notice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _notice!,
                        key: const Key('import-notice'),
                        style: TextStyle(color: colors.onSurface),
                      ),
                    ),
                  ),
                if (_tab == 0) ...[
                  if (preview != null) ...[
                    const SizedBox(height: 26),
                    _previewPanel(preview),
                  ],
                  SizedBox(height: hasSavedAccounts ? 22 : 32),
                  Text(
                    l.yourConnections,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.savedCountsNote,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _statTiles(),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    key: const Key('explore-accounts'),
                    onPressed: () => setState(() => _tab = 1),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l.exploreAccounts),
                  ),
                ],
                if (_tab == 1) ...[
                  const SizedBox(height: 24),
                  if (_fullLists)
                    TextField(
                      key: const Key('search-field'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        labelText: l.searchSavedUsernames,
                        hintText: l.usernameHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: l.searchAction,
                          onPressed: _reloadDashboard,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _reloadDashboard(),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (_fullLists)
                        _categoryChip(
                          null,
                          l.filterAll,
                          _counts.isEmpty
                              ? null
                              : _counts.values.whereType<int>().fold<int>(
                                  0,
                                  (a, b) => a + b,
                                ),
                        ),
                      for (final category in RelationshipCategory.values)
                        _categoryChip(
                          category,
                          _categoryLabel(category),
                          _counts[category],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _loadingRows && _rows.isEmpty
                        ? l.loadingSavedResults
                        : _total == 0
                        ? l.noSavedResults
                        : !_fullLists
                        ? l.sampleShowing(_rows.length, _total)
                        : l.showingResults(
                            _offset + 1,
                            _offset + _rows.length,
                            _total,
                          ),
                    key: const Key('results-count'),
                  ),
                  for (final row in _rows) _resultRow(row),
                  if (_fullLists && _total > _pageSize)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            key: const Key('previous-page'),
                            onPressed: _loadingRows || _offset == 0
                                ? null
                                : () => _changePage(_offset - _pageSize),
                            child: Text(l.previousPage),
                          ),
                          OutlinedButton(
                            key: const Key('next-page'),
                            onPressed:
                                _loadingRows || _offset + _pageSize >= _total
                                ? null
                                : () => _changePage(_offset + _pageSize),
                            child: Text(l.nextPage),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 28),
                _aboutResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboutResults() => Card(
    child: ExpansionTile(
      key: const Key('about-results'),
      title: Text(l.aboutResults),
      leading: const Icon(Icons.info_outline, size: 20),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.snapshotCaveat),
        const SizedBox(height: 10),
        Text(l.privacyDisclosure, key: const Key('privacy-copy')),
      ],
    ),
  );

  Widget _infoLinks() => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      TextButton.icon(
        key: const Key('privacy-policy-link'),
        onPressed: () => _openInfoLink(
          Uri.https('remejuan.github.io', '/instagram-manager-mobile/privacy/'),
        ),
        icon: const Icon(Icons.privacy_tip_outlined, size: 18),
        label: Text(l.privacyPolicy),
      ),
      TextButton.icon(
        key: const Key('support-link'),
        onPressed: () => _openInfoLink(
          Uri.https('remejuan.github.io', '/instagram-manager-mobile/support/'),
        ),
        icon: const Icon(Icons.help_outline, size: 18),
        label: Text(l.support),
      ),
    ],
  );

  Widget _heroCard(ParsedImport? preview, {required bool compact}) => Container(
    key: const Key('import-hero'),
    padding: EdgeInsets.all(compact ? 16 : 22),
    decoration: BoxDecoration(
      color: KinshipColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: KinshipColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          preview == null
              ? compact
                    ? l.addAnotherExport
                    : l.startWithExport
              : l.exportReady,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: compact ? 4 : 8),
        Text(compact ? l.compactExportDescription : l.exportDescription),
        SizedBox(height: compact ? 12 : 18),
        FilledButton.icon(
          key: const Key('pick-import'),
          onPressed: _busy ? null : _pick,
          icon: const Icon(Icons.file_open_outlined),
          label: Text(preview == null ? l.chooseExport : l.chooseAnotherExport),
        ),
      ],
    ),
  );

  Widget _statTiles() => LayoutBuilder(
    builder: (context, constraints) {
      final width = (constraints.maxWidth - 12) / 2;
      final total = _counts.isEmpty
          ? null
          : _counts.values.whereType<int>().fold<int>(0, (a, b) => a + b);
      final stats = [
        (l.accountsStat, total, KinshipColors.sage),
        (l.mutual, _counts[RelationshipCategory.mutual], KinshipColors.mint),
        (
          l.followingOnly,
          _counts[RelationshipCategory.followingOnly],
          KinshipColors.peach,
        ),
        (
          l.followerOnly,
          _counts[RelationshipCategory.followerOnly],
          KinshipColors.softMint,
        ),
        (
          l.unknown,
          _counts[RelationshipCategory.unknown],
          KinshipColors.warningBg,
        ),
      ];
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final (label, count, tint) in stats)
            Semantics(
              label: l.statSemantics(label, count?.toString() ?? l.unavailable),
              child: Container(
                width: width,
                constraints: const BoxConstraints(minHeight: 112),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count?.toString() ?? '—',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontSize: 36, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _previewPanel(ParsedImport preview) {
    final invalid = preview.sides.values.fold<int>(
      0,
      (n, side) => n + side.invalidCount,
    );
    final duplicates = preview.sides.values.fold<int>(
      0,
      (n, side) => n + side.duplicateCount,
    );
    return Material(
      color: KinshipColors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: KinshipColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.reviewBeforeSaving,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: _ink, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(l.partialSaferDefault),
            const SizedBox(height: 6),
            Text(l.completeCoverageExplanation),
            const SizedBox(height: 12),
            Text(
              l.recognizedSummary(
                preview.recognizedFileCount,
                invalid,
                duplicates,
              ),
            ),
            if (preview.warningCodes.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KinshipColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final warning in preview.warningCodes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(l.warningPrefix(_warningLabel(warning))),
                      ),
                  ],
                ),
              ),
            for (final side in RelationshipSide.values)
              _sideChoice(side, preview.sides[side]),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('review-import'),
              onPressed: _busy || !_allAcknowledged ? null : _reviewImport,
              child: Text(l.reviewImpact),
            ),
            if (_reviewReady) ...[
              const SizedBox(height: 18),
              const Divider(),
              Text(
                l.confirmSavedChanges,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final side in RelationshipSide.values)
                if (_proposals[side] case final proposal?)
                  _proposalPanel(proposal),
              if (_proposals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l.partialNoAbsence),
                ),
              const SizedBox(height: 10),
              FilledButton.tonal(
                key: const Key('confirm-import'),
                onPressed: _busy ? null : _confirm,
                child: Text(l.confirmSaveLocally),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sideChoice(RelationshipSide side, ParsedImportSide? data) {
    final label = side == RelationshipSide.following
        ? l.sideFollowing
        : l.sideFollowers;
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(l.missingSide(label), key: Key('missing-${side.name}')),
      );
    }
    final choice = _choices[side] ?? Coverage.partial;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.sideObservations(label, data.observations.length, data.rowCount),
            style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
          ),
          Text(l.sideInvalidDuplicates(data.invalidCount, data.duplicateCount)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                key: Key('partial-${side.name}'),
                label: Text(l.coveragePartial),
                selected: choice == Coverage.partial,
                onSelected: _busy
                    ? null
                    : (_) => _choose(side, Coverage.partial),
              ),
              ChoiceChip(
                key: Key('complete-${side.name}'),
                label: Text(l.coverageComplete),
                selected: choice == Coverage.complete,
                onSelected: _busy || data.invalidCount > 0
                    ? null
                    : (_) => _choose(side, Coverage.complete),
              ),
            ],
          ),
          if (data.invalidCount > 0) Text(l.completeUnavailable),
          CheckboxListTile(
            key: Key('ack-${side.name}'),
            contentPadding: EdgeInsets.zero,
            title: Text(l.acknowledgeSide(label, _coverageLabel(choice))),
            value: _acknowledged.contains(side),
            onChanged: _busy
                ? null
                : (value) => setState(() {
                    if (value == true) {
                      _acknowledged.add(side);
                    } else {
                      _acknowledged.remove(side);
                    }
                    _reviewReady = false;
                  }),
          ),
        ],
      ),
    );
  }

  Widget _proposalPanel(AbsenceReviewProposal proposal) {
    final label = proposal.side == RelationshipSide.following
        ? l.sideFollowingLower
        : l.sideFollowersLower;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KinshipColors.peach,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.completeSideSnapshot(label),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(l.previouslyPresentAbsence(proposal.presentCount, label)),
          Text(l.previouslyUnknownAbsence(proposal.unknownCount, label)),
          if (proposal.sample.isNotEmpty)
            Text(l.sampleAccounts(proposal.sample.take(10).join(', '))),
        ],
      ),
    );
  }

  Widget _categoryChip(
    RelationshipCategory? category,
    String label,
    int? count,
  ) => FilterChip(
    key: Key('category-${category?.name ?? 'all'}'),
    selected: _category == category,
    showCheckmark: false,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    selectedColor: KinshipColors.peach,
    backgroundColor: KinshipColors.white,
    side: const BorderSide(color: KinshipColors.line),
    label: Text(l.filterWithCount(label, count?.toString() ?? '—')),
    onSelected: (_) => _filter(category),
  );

  Widget _resultRow(RelationshipRow row) => Card(
    margin: const EdgeInsets.only(top: 8),
    child: ListTile(
      title: Text(l.usernameDisplay(row.username)),
      subtitle: Text(
        _fullLists ? _rowDescription(row) : _categoryLabel(row.category),
      ),
      onTap: () => _copy(row.username),
      onLongPress: () => _copy(row.username),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_fullLists)
            IconButton(
              key: Key('details-${row.username}'),
              tooltip: l.detailsFor(row.username),
              icon: const Icon(Icons.info_outline),
              onPressed: () => _details(row),
            ),
          IconButton(
            key: Key('profile-${row.username}'),
            tooltip: l.openProfileFor(row.username),
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _open(row.username),
          ),
        ],
      ),
    ),
  );

  Future<void> _details(RelationshipRow row) async {
    if (!_fullLists) return;
    _detailsVisible = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: KinshipColors.white,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.usernameDisplay(row.username),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_rowDescription(row)),
              const SizedBox(height: 16),
              Text(l.snapshotEvidenceNote),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _copy(row.username),
                    icon: const Icon(Icons.copy_outlined),
                    label: Text(l.copyUsername),
                  ),
                  FilledButton.icon(
                    onPressed: () => _open(row.username),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l.openProfile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    _detailsVisible = false;
  }

  String _rowDescription(RelationshipRow row) {
    final evidence = switch (row.category) {
      RelationshipCategory.followingOnly => l.notPresentFollowers(
        row.followersAbsenceImportId?.toString() ?? l.coverageUnknownLower,
      ),
      RelationshipCategory.followerOnly => l.notPresentFollowing(
        row.followingAbsenceImportId?.toString() ?? l.coverageUnknownLower,
      ),
      _ => _categoryLabel(row.category),
    };
    String latest(String label, Coverage coverage, int? importId) =>
        importId == null
        ? l.coverageWithoutImport(label, _coverageLabel(coverage))
        : l.coverageWithImport(label, _coverageLabel(coverage), importId);
    return l.rowEvidence(
      evidence,
      latest(
        l.sideFollowingLower,
        row.followingCoverage,
        row.followingCoverageImportId,
      ),
      latest(
        l.sideFollowersLower,
        row.followersCoverage,
        row.followersCoverageImportId,
      ),
    );
  }

  String _coverageLabel(Coverage coverage) => switch (coverage) {
    Coverage.partial => l.coveragePartialLower,
    Coverage.complete => l.coverageCompleteLower,
    Coverage.missing => l.coverageMissingLower,
  };

  String _categoryLabel(RelationshipCategory category) => switch (category) {
    RelationshipCategory.mutual => l.mutual,
    RelationshipCategory.followingOnly => l.followingOnly,
    RelationshipCategory.followerOnly => l.followerOnly,
    RelationshipCategory.unknown => l.unknown,
  };

  String _warningLabel(ImportWarningCode code) => switch (code) {
    ImportWarningCode.invalidRows => l.warningInvalidRows,
    ImportWarningCode.duplicateRows => l.warningDuplicateRows,
    ImportWarningCode.conflictingDuplicate => l.warningConflictingDuplicate,
  };
}
