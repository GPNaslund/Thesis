import 'hk_device.dart';
import 'hk_quantity.dart';
import 'hk_sample.dart';

class HKQuantitySample extends HKSample {
  late HKQuantity quantity;
  late int? count;

  HKQuantitySample({
    required super.uuid,
    required super.startDate,
    required super.endDate,
    super.metadata,
    HKDevice? super.device,
    super.sourceRevision,

    required this.quantity,
    required super.sampleType,
    required this.count,
  });

  @override
  String toString() {
    return 'HKQuantitySample(uuid: $uuid, quantity: $quantity, startDate: $startDate)';
  }
}
