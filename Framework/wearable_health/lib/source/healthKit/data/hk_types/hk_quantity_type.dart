import 'hk_sample_type.dart';

enum HKQuantityAggregationStyle {
  cumulative,
  discrete,
}

class HKQuantityType extends HKSampleType {
  final HKQuantityAggregationStyle aggregationStyle;

  HKQuantityType({
    required super.identifier,
    required this.aggregationStyle,
  });

  HKQuantityType.heartRate()
      : aggregationStyle = HKQuantityAggregationStyle.discrete,
        super(identifier: 'HKQuantityTypeIdentifierHeartRate');

  HKQuantityType.bodyTemperature()
      : aggregationStyle = HKQuantityAggregationStyle.discrete,
        super(identifier: 'HKQuantityTypeIdentifierBodyTemperature');

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