import 'hk_unit.dart';

class HKQuantity {
  final double doubleValue;
  final HKUnit unit;

  const HKQuantity({
    required this.doubleValue,
    required this.unit,
  });

  double getValue(HKUnit targetUnit) {
    if (unit == targetUnit) {
      return doubleValue;
    }
    throw ArgumentError('Unit mismatch: Cannot directly convert ${unit.unitString} to ${targetUnit.unitString} without conversion logic.');
  }

  Map<String, dynamic> toJson() {
    return {
      "doubleValue": doubleValue,
      "unit": unit.toString(),
    };
  }

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
    return 'HKQuantity($doubleValue ${unit.unitString})';
  }
}