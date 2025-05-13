import 'hk_device.dart';
import 'hk_sample_type.dart';

/// Base class for health data samples in HealthKit.
///
/// Represents a single health data record with timestamps and associated metadata.
/// Specific types of health data extend this class with additional properties.
class HKSample {
  /// Unique identifier for this sample.
  late String uuid;

  /// The date and time when this sample started or was recorded.
  late DateTime startDate;

  /// The date and time when this sample ended.
  ///
  /// For instantaneous measurements, may be the same as startDate.
  late DateTime endDate;

  /// The type of health data this sample contains.
  late HKSampleType sampleType;

  /// Optional additional data associated with this sample.
  ///
  /// May contain app-specific or context-specific information.
  late Map<String, dynamic>? metadata;

  /// Optional information about the device that recorded this sample.
  late HKDevice? device;

  /// Optional information about the source and version that provided this data.
  ///
  /// May include app name, version, and other source-specific details.
  late Map<String, dynamic>? sourceRevision;

  /// Creates a new sample with the specified parameters.
  ///
  /// Requires core identification and timing data, with optional
  /// metadata, device information, and source details.
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
