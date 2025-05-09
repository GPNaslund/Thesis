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
    doubleValue: _getDataTypeFromMap<double>(jsonData["value"], false)!,
    unit: HKUnit.count.divided(HKUnit.minute),
  ),
        super(
        uuid: _getDataTypeFromMap<String>(jsonData["uuid"], false)!,
        startDate: _getDataTypeFromMap<DateTime>(jsonData["startDate"], false)!,
        endDate: _getDataTypeFromMap<DateTime>(jsonData["endDate"], false)!,
        sampleType: HKSampleType(identifier: _getDataTypeFromMap<String>(jsonData["sampleType"], false)!),
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

  static T? _getDataTypeFromMap<T>(dynamic value, bool nullable) {
    if (value == null) {
      if (nullable) {
        return null;
      } else {
        throw FormatException(
            "Value is null, but type $T is not permitted to be null in this context (nullable was false).");
      }
    }

    if (value is T) {
      return value;
    }

    if (T == DateTime && value is String) {
      try {
        return DateTime.parse(value) as T?;
      } catch (e) {
        throw FormatException(
            "Could not parse String '$value' as DateTime. Original error: $e");
      }
    }

    if (T is Map<String, dynamic> && value is Map) {
      try {
        final newMap = <String, dynamic>{};
        bool allKeysAreStrings = true;
        for (final entry in value.entries) {
          if (entry.key is String) {
            newMap[entry.key as String] = entry.value;
          } else {
            allKeysAreStrings = false;
            throw FormatException(
                "Cannot convert Map to Map<String, dynamic>: Key '${entry.key}' (type: ${entry.key.runtimeType}) is not a String.");
          }
        }
        return newMap as T?;
      } catch (e) {
        if (e is FormatException) rethrow;
        throw FormatException(
            "Error converting Map (value type: ${value.runtimeType}) to Map<String, dynamic>. Original error: $e. Value: '$value'");
      }
    }

    if (value is num) {
      if (T == double && value is int) {
        return value.toDouble() as T?;
      }
      if (T == int && value is double) {
        return value.round() as T?;
      }
    }

    if (T == String) {
      return value.toString() as T?;
    }

    final String valueTypeString = value.runtimeType.toString();
    throw FormatException(
        "Cannot convert $valueTypeString ('$value') to type $T. No applicable conversion found.");
  }
}