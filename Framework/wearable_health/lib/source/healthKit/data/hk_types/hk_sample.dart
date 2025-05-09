import 'hk_device.dart';
import 'hk_sample_type.dart';
import 'hk_source_revision.dart';

class HKSample {
  late String uuid;
  late DateTime startDate;
  late DateTime endDate;
  late HKSampleType sampleType;
  late Map<String, dynamic>? metadata;
  late HKDevice? device;
  late Map<String, dynamic>? sourceRevision;

  HKSample({
    required this.uuid,
    required this.startDate,
    required this.endDate,
    required this.sampleType,
    this.metadata,
    this.device,
    this.sourceRevision,
  });
}