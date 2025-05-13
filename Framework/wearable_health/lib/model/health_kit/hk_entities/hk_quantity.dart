class HKQuantity {
  final double doubleValue;
  final String unit;

  const HKQuantity(
    double value, {
    required this.doubleValue,
    required this.unit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HKQuantity &&
          runtimeType == other.runtimeType &&
          doubleValue == other.doubleValue &&
          unit == other.unit;

  @override
  int get hashCode => doubleValue.hashCode ^ unit.hashCode;

  @override
  String toString() {
    return 'HKQuantity($doubleValue $unit)';
  }
}
