import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/domain/result.dart';

String describe<T>(Result<T> result) => switch (result) {
  Success(:final value) => 'success:$value',
  Failure(:final error) => 'failure:${error.category.name}',
};

void main() {
  test('success carries value and supports exhaustive consumption', () {
    const Result<int> result = Success(42);
    expect(describe(result), 'success:42');
    expect((result as Success<int>).value, 42);
  });

  test('failure carries finite category without raw user data', () {
    const Result<String> result = Failure(
      DomainFailure(DomainFailureCategory.invalidInput),
    );
    expect(describe(result), 'failure:invalidInput');
    expect(result.toString(), isNot(contains('secret_username')));
  });

  test('failure string contains category but no relationship data', () {
    const failure = DomainFailure(DomainFailureCategory.persistenceUnavailable);
    expect(
      failure.toString(),
      'Domain operation failed: persistenceUnavailable',
    );
    expect(failure.toString(), isNot(contains('alice')));
  });
}
