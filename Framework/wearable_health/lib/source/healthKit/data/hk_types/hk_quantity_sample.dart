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
    doubleValue: _getDataTypeFromMap<double>(jsonData["value"]),
    unit: HKUnit.count.divided(HKUnit.minute),
  ),
        super(
        uuid: _getDataTypeFromMap<String>(jsonData["uuid"]),
        startDate: _getDataTypeFromMap<DateTime>(jsonData["startDate"]),
        endDate: _getDataTypeFromMap<DateTime>(jsonData["endDate"]),
        sampleType: HKSampleType(identifier: _getDataTypeFromMap<String>(jsonData["sampleType"])),
        metadata: jsonData["metadata"] != null
            ? _extractMap(jsonData["metadata"])
            : null,
        device: jsonData["device"] != null
            ? HKDevice.fromMap(_extractMap(jsonData["device"]))
            : null,
        sourceRevision: jsonData["sourceRevision"] != null
            ? HKSourceRevision.fromMap(_extractMap(jsonData["sourceRevision"]))
            : null,
      );

  static Map<String, dynamic> _extractMap(dynamic value) {
    if (value == null) {
        throw FormatException("Value is null, but a Map was expected and nullable was false.");
    }

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      final newMap = <String, dynamic>{};
      for (final entry in value.entries) {
        if (entry.key is String) {
          newMap[entry.key as String] = entry.value;
        } else {
          throw FormatException(
              "Map key is not a String. Key: '${entry.key}', Type: ${entry.key.runtimeType}");
        }
      }
      return newMap;
    }

    throw FormatException("Value is not a map. Type was: ${value.runtimeType}");
  }

  static T _getDataTypeFromMap<T>(dynamic value) {
    if (value == null) {
        throw FormatException(
            "Value is null, but type $T is not permitted to be null in this context (nullable was false).");
    }

    if (value is T) {
      return value;
    }

    if (T == DateTime && value is String) {
      try {
        return DateTime.parse(value) as T;
      } catch (e) {
        throw FormatException(
            "Could not parse String '$value' as DateTime. Original error: $e");
      }
    }

    if (value is num) {
      if (T == double && value is int) {
        return value.toDouble() as T;
      }
      if (T == int && value is double) {
        return value.round() as T;
      }
    }

    if (T == String) {
      return value.toString() as T;
    }

    final String valueTypeString = value.runtimeType.toString();
    throw FormatException(
        "Cannot convert $valueTypeString ('$value') to type $T. No applicable conversion found.");
  }
}