import 'package:wearable_health/source/healthKit/data/hk_types/hk_sample_type.dart';
import 'package:wearable_health/source/healthKit/data/hk_types/hk_source_revision.dart';
import 'package:wearable_health/source/healthKit/data/hk_types/hk_unit.dart';

import 'hk_device.dart';
import 'hk_quantity.dart';
import 'hk_sample.dart';

class HKQuantitySample extends HKSample {
  late HKQuantity quantity;


  HKQuantitySample({
    required super.uuid,
    required super.startDate,
    required super.endDate,
    super.metadata,
    HKDevice? super.device,
    super.sourceRevision,

    required this.quantity,
    required super.sampleType,
  });

  @override
  String toString() {
    return 'HKQuantitySample(uuid: $uuid, quantity: $quantity, startDate: $startDate)';
  }

  Map<String, dynamic> toJson() {
    var result = {
      "uuid": uuid,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "quantity": quantity.toJson(),
      "sampleType": sampleType.identifier,
    };

    if (metadata != null) {
      result["metadata"] = metadata!;
    }
    if (device != null) {
      result["device"] = device!.toJson();
    }
    if (sourceRevision != null) {
      result["sourceRevision"] = sourceRevision!.toJson();
    }

    return result;
  }

  HKQuantitySample.fromJson(Map<String, dynamic> jsonData)
      : quantity = HKQuantity(
    doubleValue: _getDataTypeFromMap<double>(jsonData["value"], false),
    unit: HKUnit.count.divided(HKUnit.minute),
  ),
        super(
        uuid: _getDataTypeFromMap<String>(jsonData["uuid"], false),
        startDate: _getDataTypeFromMap<DateTime>(jsonData["startDate"], false),
        endDate: _getDataTypeFromMap<DateTime>(jsonData["endDate"], false),
        sampleType: HKSampleType(identifier: _getDataTypeFromMap<String>(jsonData["sampleType"], false)),
        metadata: jsonData["metadata"] != null
            ? _getDataTypeFromMap<Map<String, dynamic>>(jsonData["metadata"], true)
            : null,
        device: jsonData["device"] != null
            ? HKDevice.fromMap(jsonData["device"])
            : null,
        sourceRevision: jsonData["sourceRevision"] != null
            ? HKSourceRevision.fromMap(jsonData["sourceRevision"])
            : null,
      );

  static T _getDataTypeFromMap<T>(dynamic value, bool nullable) {
    if (T == DateTime) {
      if (value is String) {
        try {
          return DateTime.parse(value) as T;
        } catch (e) {
          throw FormatException(
              "Could not parse String '$value' as DateTime. Original error: $e");
        }
      } else if (value is DateTime) {
        return value as T;
      } else {
        throw FormatException(
            "Expected a String or DateTime for DateTime conversion, but got ${value?.runtimeType} ('$value')");
      }
    } else if (value is T) {
      return value;
    } else {
      if (value is num) {
        if (T == double) {
          return value.toDouble() as T;
        }
        if (T == int) {
          return value.toInt() as T;
        }
      }
      final String valueTypeString = value?.runtimeType.toString() ?? 'null';
      throw FormatException(
          "Cannot convert $valueTypeString ('$value') to type $T.");
    }
  }
}