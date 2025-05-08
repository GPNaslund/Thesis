import 'hk_device.dart';
import 'hk_quantity.dart';
import 'hk_quantity_type.dart';
import 'hk_sample.dart';

class HKQuantitySample extends HKSample {
  final HKQuantity quantity;
  final int count;
  HKQuantityType get quantityType => sampleType as HKQuantityType;

  HKQuantitySample({
    required super.uuid,
    required super.startDate,
    required super.endDate,
    required super.hasUndeterminedDuration,
    super.metadata,
    HKDevice? super.device,
    super.sourceRevision,

    required HKQuantityType hkQuantityTypeParameter,
    required this.quantity,
    required this.count,
  }) : super(
    sampleType: hkQuantityTypeParameter,
  );

  @override
  String toString() {
    return 'HKQuantitySample(uuid: $uuid, quantity: $quantity, count: $count, startDate: $startDate, quantityType: ${quantityType.toString()})';
  }


}