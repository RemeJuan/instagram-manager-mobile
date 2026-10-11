import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/purchases/capability_policy.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';

void main() {
  group('CapabilityPolicy', () {
    test(
      'sets bounded free sample and denies full lists for inactive access',
      () {
        const policy = CapabilityPolicy(
          PurchaseSnapshot(EntitlementState.inactive),
        );
        expect(CapabilityPolicy.freeSampleLimit, 10);
        expect(policy.canViewCompleteLists, isFalse);
        expect(policy.allows(ProCapability.advancedInsights), isFalse);
      },
    );

    test('unknown access remains bounded and does not imply paid access', () {
      const policy = CapabilityPolicy(
        PurchaseSnapshot(EntitlementState.unknown),
      );
      expect(policy.canViewCompleteLists, isFalse);
      expect(policy.allows(ProCapability.exportHistory), isFalse);
    });

    test('active entitlement permits complete lists', () {
      const policy = CapabilityPolicy(
        PurchaseSnapshot(EntitlementState.active),
      );
      expect(policy.canViewCompleteLists, isTrue);
      expect(policy.allows(ProCapability.advancedInsights), isTrue);
    });
  });
}
