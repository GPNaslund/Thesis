import 'hk_device.dart';
import 'hk_sample_type.dart';
import 'hk_source_revision.dart';

class HKSample {
  final String uuid;
  final DateTime startDate;
  final DateTime endDate;
  final bool hasUndeterminedDuration;
  final HKSampleType sampleType;
  final Map<String, dynamic>? metadata;
  final HKDevice? device;
  final HKSourceRevision? sourceRevision;

  HKSample({
    required this.uuid,
    required this.startDate,
    required this.endDate,
    required this.hasUndeterminedDuration,
    required this.sampleType,
    this.metadata,
    this.device,
    this.sourceRevision,
  });
}