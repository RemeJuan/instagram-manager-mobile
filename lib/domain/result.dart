/// Finite failure categories exposed by domain operations.
enum DomainFailureCategory {
  invalidInput,
  unsupportedCoverage,
  persistenceUnavailable,
}

/// Safe, user-data-free failure description for a domain operation.
final class DomainFailure {
  const DomainFailure(this.category);

  final DomainFailureCategory category;

  @override
  String toString() => 'Domain operation failed: ${category.name}';
}

/// Result contract. Consumers must handle both variants exhaustively:
/// `switch (result) { Success(:final value) => ..., Failure(:final error) => ... }`.
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final DomainFailure error;
}
