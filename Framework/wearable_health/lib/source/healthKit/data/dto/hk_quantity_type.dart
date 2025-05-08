import 'hk_sample_type.dart';

enum HKQuantityAggregationStyle {
  cumulative,
  discrete,
}

class HKQuantityType extends HKSampleType {
  final HKQuantityAggregationStyle aggregationStyle;

  const HKQuantityType({
    required super.identifier,
    required this.aggregationStyle,
  });

  static const HKQuantityType heartRate = HKQuantityType(
    identifier: 'HKQuantityTypeIdentifierHeartRate',
    aggregationStyle: HKQuantityAggregationStyle.discrete,
  );

  static const HKQuantityType bodyTemperature = HKQuantityType(
    identifier: 'HKQuantityTypeIdentifierBodyTemperature',
    aggregationStyle: HKQuantityAggregationStyle.discrete,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is HKQuantityType &&
              runtimeType == other.runtimeType &&
              aggregationStyle == other.aggregationStyle;

  @override
  int get hashCode => super.hashCode ^ aggregationStyle.hashCode;

  @override
  String toString() {
    return 'HKQuantityType($identifier, $aggregationStyle)';
  }
}