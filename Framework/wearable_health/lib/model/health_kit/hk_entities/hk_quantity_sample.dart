import 'package:flutter/cupertino.dart';

import 'hk_device.dart';
import 'hk_quantity.dart';
import 'hk_sample.dart';

/// Represents a sample of quantitative health data in HealthKit.
///
/// Contains a measured quantity with an optional count and inherits
/// common sample attributes from [HKSample].
class HKQuantitySample extends HKSample {
  /// The measured health quantity value with its unit.
  late HKQuantity quantity;

  /// Optional count of measurements combined in this sample.
  ///
  /// May represent number of readings, occurrences, or data points.
  late int? count;

  /// Creates a new quantity sample with the specified parameters.
  ///
  /// Requires core sample data plus a quantity measurement. The count
  /// parameter is required but can be null.
  HKQuantitySample({
    required super.uuid,
    required super.startDate,
    required super.endDate,
    super.metadata,
    super.device,
    super.sourceRevision,
    required this.quantity,
    required super.sampleType,
    this.count,
  });

  /// Returns a string representation of this quantity sample.
  ///
  /// Format: 'HKQuantitySample(uuid: uuid, quantity: quantity, startDate: startDate)'
  @override
  String toString() {
    return 'HKQuantitySample(uuid: $uuid, quantity: $quantity, startDate: $startDate)';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "uuid": uuid,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "quantity": quantity.toJson(),
      "sampleType": sampleType.toString(),
    };

    if (metadata != null) {
      result["metadata"] = metadata;
    }
    if (device != null) {
      result["device"] = device!.toJson();
    }
    if (sourceRevision != null) {
      result["sourceRevision"] = sourceRevision;
    }
    if (count != null) {
      result["count"] = count;
    }

    return result;
  }
}
