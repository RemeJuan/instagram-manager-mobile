import 'purchase_gateway.dart';

enum ProCapability { advancedInsights, exportHistory }

/// Central feature policy. Import and all safety/privacy controls stay available.
class CapabilityPolicy {
  static const int freeSampleLimit = 10;

  const CapabilityPolicy(this.snapshot);

  final PurchaseSnapshot snapshot;

  bool allows(ProCapability capability) => snapshot.isPro;

  bool get canViewCompleteLists => snapshot.isPro;

  bool get canImport => true;
  bool get canValidate => true;
  bool get canViewCoverageWarnings => true;
  bool get canUsePrivacyControls => true;
  bool get canRestore => true;
}
