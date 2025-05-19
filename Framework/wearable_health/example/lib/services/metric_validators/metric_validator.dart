// lib/services/metric_validators/metric_validator.dart

/// A base class for validating a list of health data entries of a specific format.
abstract class MetricValidator<T> {
  /// Validates each entry and returns a list of validation results.
  /// Each result contains a status message for the corresponding record.
  List<ValidationResult> validateAll(List<T> entries);

  /// Validates a single entry.
  ValidationResult validate(T entry);
}

/// A class representing the result of a validation.
class ValidationResult {
  final bool isValid;
  final String summary;
  final Map<String, dynamic>? details;

  const ValidationResult({
    required this.isValid,
    required this.summary,
    this.details,
  });
}