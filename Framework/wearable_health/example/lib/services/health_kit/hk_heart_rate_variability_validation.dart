import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart'; // Target HealthKit HRV object model.
import 'package:wearable_health/service/health_kit/data_factory_interface.dart'; // Interface for the factory.

/// Validates the integrity and consistency of raw HealthKit Heart Rate Variability (HRV) data
/// when converted into a structured [HKHeartRateVariability] object and subsequently
/// into an OpenMHealth HRV representation.
///
/// This function performs a multi-step validation similar to heart rate validation:
/// 1.  Uses the provided [hkDataFactory] to create an [HKHeartRateVariability] object
///     from the [rawData] map.
/// 2.  Converts the created [HKHeartRateVariability] object into its OpenMHealth format.
/// 3.  Compares various fields from the original [rawData] (UUID, start/end dates,
///     quantity, sample type, count, metadata, device, source revision) against
///     the corresponding fields in the instantiated [HKHeartRateVariability] object.
/// 4.  Performs detailed validation for nested structures like 'quantity',
///     'metadata', 'device', and 'sourceRevision'.
/// 5.  Compares critical fields (HRV value, unit, and effective time) from the
///     [HKHeartRateVariability] object against the generated OpenMHealth representation.
///
/// If any discrepancy is detected, a message is logged, and the function immediately returns `false`.
///
/// Parameters:
///  - [rawData]: A `Map<String, dynamic>` containing the raw HealthKit HRV data.
///    Expected to conform to HealthKit's structure for HRV samples.
///  - [hkDataFactory]: An instance of [HKDataFactory] capable of creating an
///    [HKHeartRateVariability] object from `rawData`.
///
/// Returns:
///  - `true` if all data fields are consistent across raw data, the [HKHeartRateVariability] object,
///    and (where applicable) the OpenMHealth object.
///  - `false` if any discrepancy or inconsistency is found.
bool isValidHKHeartRateVariability(Map<String, dynamic> rawData,
    HKDataFactory hkDataFactory) {
  // var isValid = true; // This flag can be removed if all failure paths use 'return false;'

  // Step 1: Create HKHeartRateVariability object.
  var obj = hkDataFactory.createHeartRateVariability(rawData);
  // Step 2: Convert to OpenMHealth format.
  var openMHealth = obj
      .toOpenMHealthHeartRateVariability(); // Assuming this returns a list.

  // --- Raw Value Extraction ---
  // Required raw fields:
  var rawUuid = rawData["uuid"];
  var rawStartDateStr = rawData["startDate"];
  var rawEndDateStr = rawData["endDate"];
  var rawQuantity = rawData["quantity"];
  var rawSampleType = rawData["sampleType"];
  // Optional raw fields:
  var rawCount = rawData["count"];
  var rawMetadata = rawData["metadata"];
  var rawDevice = rawData["device"];
  var rawSourceRevision = rawData["sourceRevision"];

  // --- Validation against HKHeartRateVariability object (`obj`) ---

  // Validate UUID.
  if (rawUuid != obj.data.uuid) {
    log("found discrepancy: raw uuid $rawUuid - obj uuid ${obj.data.uuid}");
    return false; // Discrepancy, return false.
  }

  // Validate start date.
  // Ensure rawStartDateStr is not null and is a String before parsing.
  if (rawStartDateStr == null || rawStartDateStr is! String) {
    log(
        "Found discrepancy: raw startDate is null or not a String: $rawStartDateStr");
    return false;
  }
  try {
    if (!obj.data.startDate.isAtSameMomentAs(DateTime.parse(rawStartDateStr))) {
      log(
          "found discrepancy: raw start date: $rawStartDateStr - obj start date ${obj
              .data.startDate.toIso8601String()}");
      return false;
    }
  } catch (e) {
    log("Error parsing raw startDate '$rawStartDateStr': $e");
    return false;
  }

  // Validate end date.
  // Ensure rawEndDateStr is not null and is a String before parsing.
  if (rawEndDateStr == null || rawEndDateStr is! String) {
    log(
        "Found discrepancy: raw endDate is null or not a String: $rawEndDateStr");
    return false;
  }
  try {
    if (!obj.data.endDate.isAtSameMomentAs(DateTime.parse(rawEndDateStr))) {
      log("found discrepancy: raw end date: $rawEndDateStr - obj end date: ${obj
          .data.endDate.toIso8601String()}");
      return false;
    }
  } catch (e) {
    log("Error parsing raw endDate '$rawEndDateStr': $e");
    return false;
  }

  // Validate 'quantity' (nested map with 'value' and 'unit').
  // Reusing the _validateQuantity helper, assuming its structure is identical for HRV quantity.
  // If HRV quantity structure differs, a new helper or modified logic would be needed.
  // For this example, we assume it's the same structure as heart rate quantity.
  var validQuantity = _validateHrvQuantity(rawQuantity,
      obj); // Changed to a potentially specific HRV quantity validator
  if (!validQuantity) {
    // _validateHrvQuantity will log its own discrepancies.
    return false;
  }

  // Validate 'sampleType'.
  if (rawSampleType != obj.data.sampleType.identifier) {
    log(
        "found discrepancy: raw sample type: $rawSampleType - obj sample type ${obj
            .data.sampleType.identifier}");
    return false;
  }

  // Validate 'count' (optional).
  if (rawCount != null) {
    if (rawCount != obj.data.count) {
      log("found discrepancy: raw count: $rawCount - obj count: ${obj.data
          .count}");
      return false;
    }
  } else if (obj.data.count != null) {
    log("found discrepancy: raw count is null, but obj count is ${obj.data
        .count}");
    return false;
  }

  // Validate 'metadata' (optional, nested map).
  if (rawMetadata != null) {
    if (rawMetadata is Map<Object?, Object?>) {
      bool isMetadataCurrentlyValid = true;
      rawMetadata.forEach((key, value) {
        if (obj.data.metadata == null || value != obj.data.metadata![key]) {
          log(
              "found discrepancy: raw metadata '$key' had value $value - obj had: ${obj
                  .data.metadata != null
                  ? obj.data.metadata![key]
                  : 'null metadata object'}");
          isMetadataCurrentlyValid = false;
        }
      });
      if (!isMetadataCurrentlyValid) {
        return false;
      }
      if (obj.data.metadata != null &&
          obj.data.metadata!.keys.length != rawMetadata.keys.length) {
        log("Found discrepancy: raw metadata key count ${rawMetadata.keys
            .length} different from object metadata key count ${obj.data
            .metadata!.keys.length}");
        // Potentially: return false;
      }
    } else {
      log(
          "found discrepancy: rawMetadata is not Map<Object?, Object?>. Found: ${rawMetadata
              .runtimeType}");
      return false;
    }
  } else if (obj.data.metadata != null && obj.data.metadata!.isNotEmpty) {
    log(
        "found discrepancy: raw metadata is null, but obj metadata is not empty: ${obj
            .data.metadata}");
    return false;
  }

  // Validate 'device' (optional, nested map).
  // Reusing the _validateDevice helper, assuming its structure is identical.
  var validDevice = _validateHrvDevice(
      rawDevice, obj); // Changed to a potentially specific HRV device validator
  if (!validDevice) {
    // _validateHrvDevice will log its own discrepancies.
    return false;
  }

  // Validate 'sourceRevision' (optional, nested map).
  if (rawSourceRevision != null) {
    if (rawSourceRevision is Map<Object?, Object?>) {
      bool isSourceRevisionCurrentlyValid = true;
      rawSourceRevision.forEach((key, value) {
        if (obj.data.sourceRevision == null ||
            value != obj.data.sourceRevision![key]) {
          log(
              "found discrepancy: raw source revision '$key' had value '$value' - obj value ${obj
                  .data.sourceRevision != null
                  ? obj.data.sourceRevision![key]
                  : 'null sourceRevision object'}");
          isSourceRevisionCurrentlyValid = false;
        }
      });
      if (!isSourceRevisionCurrentlyValid) {
        return false;
      }
      if (obj.data.sourceRevision != null &&
          obj.data.sourceRevision!.keys.length !=
              rawSourceRevision.keys.length) {
        log("Found discrepancy: raw sourceRevision key count ${rawSourceRevision
            .keys.length} different from object sourceRevision key count ${obj
            .data.sourceRevision!.keys.length}");
        // Potentially: return false;
      }
    } else {
      log(
          "found discrepancy: raw source revision is not Map<Object?, Object?>. Found: ${rawSourceRevision
              .runtimeType}");
      return false;
    }
  } else
  if (obj.data.sourceRevision != null && obj.data.sourceRevision!.isNotEmpty) {
    log(
        "found discrepancy: raw source revision is null, but obj source revision is not empty: ${obj
            .data.sourceRevision}");
    return false;
  }

  // --- Validation against OpenMHealth object (`openMHealth`) ---
  if (openMHealth.isEmpty) {
    log(
        "found discrepancy: OpenMHealth conversion for HRV resulted in an empty list.");
    return false;
  }
  var omhObj = openMHealth[0]; // Assuming the first object is the relevant one.

  // Validate HRV value consistency.
  if (omhObj.heartRateVariability.value != obj.data.quantity.value) {
    log("found discrepancy: obj heart rate variability: ${obj.data.quantity
        .value} - omh value: ${omhObj.heartRateVariability.value}");
    return false;
  }

  // Validate HRV unit consistency.
  if (omhObj.heartRateVariability.unit != obj.data.quantity.unit) {
    log("found discrepancy: obj heart rate variability unit ${obj.data.quantity
        .unit} - omh unit: ${omhObj.heartRateVariability.unit}");
    return false;
  }

  // Validate effective time frame consistency.
  // Note: The original had a log statement here but no `return false` or `return !isValid`.
  // This meant a discrepancy would be logged but validation would still pass if this was the only issue.
  // Corrected to return false on discrepancy.
  if (omhObj.effectiveTimeFrame.dateTime == null) {
    log(
        "found discrepancy: OpenMHealth effectiveTimeFrame.dateTime is null for HRV.");
    return false;
  }
  if (!omhObj.effectiveTimeFrame.dateTime!.isAtSameMomentAs(obj.data
      .startDate)) { // Assuming effective time for HRV point aligns with startDate
    log("found discrepancy: obj heart rate date: ${obj.data.startDate
        .toString()} - omh effective time: ${omhObj.effectiveTimeFrame.dateTime
        .toString()}");
    return false; // Added return false for discrepancy
  }

  // If all checks passed
  return true; // All checks passed.
}

/// Helper function to validate the 'quantity' field for HRV.
/// Assumes a structure with 'value' and 'unit'.
///
/// Parameters:
///  - [rawQuantity]: The raw 'quantity' map from the input HRV data.
///  - [obj]: The instantiated [HKHeartRateVariability] object.
///
/// Returns:
///  - `true` if value and unit match, `false` otherwise.
bool _validateHrvQuantity(dynamic rawQuantity, HkHeartRateVariability obj) {
  // var isValid = true; // Can be removed
  if (rawQuantity is Map<Object?, Object?>) {
    if (rawQuantity.containsKey("value")) {
      if (rawQuantity.containsKey("unit")) {
        if (rawQuantity["value"] != obj.data.quantity.value) {
          log(
              "found discrepancy: raw quantity value: ${rawQuantity["value"]} - obj quantity value: ${obj
                  .data.quantity.value}");
          return false;
        }
        if (rawQuantity["unit"] != obj.data.quantity.unit) {
          log(
              "found discrepancy: raw quantity unit: ${rawQuantity["unit"]} - obj quantity unit: ${obj
                  .data.quantity.unit}");
          return false;
        }
      } else {
        log("found discrepancy: raw quantity did not contain key 'unit'");
        return false;
      }
    } else {
      log("found discrepancy: raw quantity did not contain key 'value'");
      return false;
    }
  } else {
    log(
        "found discrepancy: raw quantity is not a Map<Object?, Object?>. Found: ${rawQuantity
            .runtimeType}");
    return false;
  }
  return true; // All checks passed for quantity
}

/// Helper function to validate the 'device' field for HRV.
/// Assumes a structure with device properties like name, manufacturer, etc.
///
/// Parameters:
///  - [rawDevice]: The raw 'device' map from the input HRV data.
///  - [obj]: The instantiated [HKHeartRateVariability] object.
///
/// Returns:
///  - `true` if fields match or both are appropriately null/empty, `false` otherwise.
bool _validateHrvDevice(dynamic rawDevice, HkHeartRateVariability obj) {
  // var isValid = true; // Can be removed

  if (rawDevice != null) {
    if (obj.data.device == null) {
      log(
          "found discrepancy: raw device is present but obj device is null for HRV.");
      return false;
    }
    if (rawDevice is Map<Object?, Object?>) {
      var rawDeviceName = rawDevice["name"];
      var rawDeviceManufacturer = rawDevice["manufacturer"];
      var rawDeviceModel = rawDevice["model"];
      var rawDeviceHardwareVersion = rawDevice["hardwareVersion"] ??
          rawDevice["hardwareVerison"]; // Handle typo
      var rawDeviceSoftwareVersion = rawDevice["softwareVersion"];

      if (rawDeviceName != null) {
        if (rawDeviceName != obj.data.device!.name) {
          log(
              "found discrepancy: raw device name $rawDeviceName - obj device name ${obj
                  .data.device!.name}");
          return false;
        }
      } else if (obj.data.device!.name != null) {
        log(
            "found discrepancy: raw device name is null, but obj device name is ${obj
                .data.device!.name}");
        return false;
      }

      if (rawDeviceManufacturer != null) {
        if (rawDeviceManufacturer != obj.data.device!.manufacturer) {
          log(
              "found discrepancy: raw device manufacturer: $rawDeviceManufacturer - obj device manufacturer ${obj
                  .data.device!.manufacturer}");
          return false;
        }
      } else if (obj.data.device!.manufacturer != null) {
        log(
            "found discrepancy: raw device manufacturer is null, but obj device manufacturer is ${obj
                .data.device!.manufacturer}");
        return false;
      }

      if (rawDeviceModel != null) {
        if (rawDeviceModel != obj.data.device!.model) {
          log(
              "found discrepancy: raw device model $rawDeviceModel - obj device model ${obj
                  .data.device!.model}");
          return false;
        }
      } else if (obj.data.device!.model != null) {
        log(
            "found discrepancy: raw device model is null, but obj device model is ${obj
                .data.device!.model}");
        return false;
      }

      if (rawDeviceHardwareVersion != null) {
        if (rawDeviceHardwareVersion != obj.data.device!.hardwareVersion) {
          log(
              "found discrepancy: raw device hardware version $rawDeviceHardwareVersion - obj device hardware version ${obj
                  .data.device!.hardwareVersion}");
          return false;
        }
      } else if (obj.data.device!.hardwareVersion != null) {
        log(
            "found discrepancy: raw device hardware version is null, but obj device hardware version is ${obj
                .data.device!.hardwareVersion}");
        return false;
      }

      if (rawDeviceSoftwareVersion != null) {
        if (rawDeviceSoftwareVersion != obj.data.device!.softwareVersion) {
          log(
              "found discrepancy: raw device software version $rawDeviceSoftwareVersion - obj device software version ${obj
                  .data.device!.softwareVersion}");
          return false;
        }
      } else if (obj.data.device!.softwareVersion != null) {
        log(
            "found discrepancy: raw device software version is null, but obj device software version is ${obj
                .data.device!.softwareVersion}");
        return false;
      }
    } else {
      log(
          "found discrepancy: raw device is not Map<Object?, Object?>. Found: ${rawDevice
              .runtimeType}");
      return false;
    }
  } else if (obj.data.device != null) {
    log(
        "found discrepancy: raw device is null, but obj device is not null for HRV: ${obj
            .data.device}");
    return false;
  }
  return true; // All checks passed for device
}
