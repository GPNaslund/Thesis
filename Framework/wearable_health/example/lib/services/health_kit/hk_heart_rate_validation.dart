import 'dart:developer'; // Used for logging discrepancies found during validation.

import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart'; // For .toOpenMHealthHeartRate()
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart'; // The target HealthKit Heart Rate object model.
import 'package:wearable_health/service/health_kit/data_factory_interface.dart'; // Interface for the factory.

/// Validates the integrity and consistency of raw HealthKit heart rate data
/// when converted into a structured [HKHeartRate] object and subsequently
/// into an OpenMHealth heart rate representation.
///
/// This function performs a multi-step validation:
/// 1.  Uses the provided [hkDataFactory] to create an [HKHeartRate] object
///     from the [rawData] map.
/// 2.  Converts the created [HKHeartRate] object into its OpenMHealth format.
/// 3.  Compares various fields from the original [rawData] (UUID, start/end dates,
///     quantity, sample type, count, metadata, device, source revision) against
///     the corresponding fields in the instantiated [HKHeartRate] object.
/// 4.  Performs detailed validation for nested structures like 'quantity',
///     'metadata', 'device', and 'sourceRevision' to ensure their individual
///     fields also match.
/// 5.  Compares critical fields (heart rate value and effective time) from the
///     [HKHeartRate] object against the generated OpenMHealth representation
///     to ensure consistency after the second conversion.
///
/// If any discrepancy is detected at any step, a message is logged to the console,
/// and the function immediately returns `false`.
///
/// Parameters:
///  - [rawData]: A `Map<String, dynamic>` containing the raw HealthKit heart rate data.
///    Expected to conform to the structure HealthKit provides for heart rate samples.
///  - [hkDataFactory]: An instance of [HKDataFactory] capable of creating an
///    [HKHeartRate] object from the provided `rawData`.
///
/// Returns:
///  - `true` if all data fields are consistent across the raw data, the
///    [HKHeartRate] object, and (where applicable) the OpenMHealth object.
///  - `false` if any discrepancy or inconsistency is found.
bool isValidHKHeartRate(Map<String, dynamic> rawData,
    HKDataFactory hkDataFactory,) {
  // Flag to track validation status. While the function returns early on failure,
  // this is used in some conditional logic for returning.
  // Could be removed if all failing paths simply `return false;`.
  var isValid = true;

  // Step 1: Create HKHeartRate object using the factory.
  var obj = hkDataFactory.createHeartRate(rawData);
  // Step 2: Convert the HKHeartRate object to its OpenMHealth representation.
  var openMHealth = obj
      .toOpenMHealthHeartRate(); // Assuming this returns a list, usually of one item for a single HK sample.

  // --- Raw Value Extraction (for direct comparison) ---
  // These are fetched from the rawData map to compare against the parsed 'obj'.

  // Required raw fields:
  var rawUuid = rawData["uuid"];
  var rawStartDateStr = rawData["startDate"]; // Expected to be an ISO 8601 String
  var rawEndDateStr = rawData["endDate"]; // Expected to be an ISO 8601 String
  var rawQuantity = rawData["quantity"]; // Expected to be a Map
  var rawSampleType = rawData["sampleType"]; // Expected to be a String (HealthKit identifier)

  // Optional raw fields:
  var rawCount = rawData["count"];
  var rawMetadata = rawData["metadata"]; // Expected to be a Map
  var rawDevice = rawData["device"]; // Expected to be a Map
  var rawSourceRevision = rawData["sourceRevision"]; // Expected to be a Map

  // --- Validation against HKHeartRate object (`obj`) ---

  // Validate UUID.
  if (rawUuid != obj.data.uuid) {
    log("found discrepancy: raw uuid $rawUuid - obj uuid ${obj.data.uuid}");
    return !isValid; // Equivalent to 'return false;'
  }

  // Validate start date.
  // Ensure rawStartDateStr is not null and is a String before parsing.
  if (rawStartDateStr == null || rawStartDateStr is! String) {
    log(
        "Found discrepancy: raw startDate is null or not a String: $rawStartDateStr");
    return !isValid;
  }
  try {
    if (!obj.data.startDate.isAtSameMomentAs(DateTime.parse(rawStartDateStr))) {
      log(
          "found discrepancy: raw start date: $rawStartDateStr - obj start date ${obj
              .data.startDate.toIso8601String()}");
      return !isValid;
    }
  } catch (e) {
    log("Error parsing raw startDate '$rawStartDateStr': $e");
    return !isValid;
  }


  // Validate end date.
  // Ensure rawEndDateStr is not null and is a String before parsing.
  if (rawEndDateStr == null || rawEndDateStr is! String) {
    log(
        "Found discrepancy: raw endDate is null or not a String: $rawEndDateStr");
    return !isValid;
  }
  try {
    if (!obj.data.endDate.isAtSameMomentAs(DateTime.parse(rawEndDateStr))) {
      log(
          "found discrepancy: raw end date: $rawEndDateStr - obj end date ${obj
              .data.endDate.toIso8601String()}");
      return !isValid;
    }
  } catch (e) {
    log("Error parsing raw endDate '$rawEndDateStr': $e");
    return !isValid;
  }

  // Validate 'quantity' (which is a nested map with 'value' and 'unit').
  var validQuantity = _validateQuantity(rawQuantity, obj);
  if (!validQuantity) {
    // _validateQuantity will log its own discrepancies.
    return !isValid;
  }

  // Validate 'sampleType'.
  if (rawSampleType != obj.data.sampleType.identifier) {
    log(
        "found discrepancy: raw sample type: $rawSampleType - obj sample type ${obj
            .data.sampleType.identifier}");
    return !isValid;
  }

  // Validate 'count' (optional field).
  if (rawCount != null) {
    if (rawCount != obj.data.count) {
      log("found discrepancy: raw count: $rawCount - obj count: ${obj.data
          .count}");
      return !isValid;
    }
  } else if (obj.data.count != null) {
    // If rawCount is null, obj.data.count should also be null (or its default if applicable, e.g. 1 for some HK types if not grouped).
    // Assuming if rawCount is null, obj.data.count should reflect that absence.
    log("found discrepancy: raw count is null, but obj count is ${obj.data
        .count}");
    return !isValid;
  }

  // Validate 'metadata' (optional field, a nested map).
  if (rawMetadata != null) {
    if (rawMetadata is Map<Object?, Object?>) {
      // Create a temporary flag for metadata loop validation to avoid modifying outer `isValid` directly in loop.
      bool isMetadataCurrentlyValid = true;
      rawMetadata.forEach((key, value) {
        if (obj.data.metadata == null || value != obj.data.metadata![key]) {
          log(
              "found discrepancy: raw metadata '$key' had value $value - obj had: ${obj
                  .data.metadata != null
                  ? obj.data.metadata![key]
                  : 'null metadata object'}");
          isMetadataCurrentlyValid = false;
          // Note: Cannot 'return !isValid' from forEach directly.
        }
      });
      if (!isMetadataCurrentlyValid) {
        return !isValid; // Return false if any metadata discrepancy was found.
      }
      // Also check if obj.data.metadata contains keys not in rawMetadata (if that's a validation criteria)
      if (obj.data.metadata != null &&
          obj.data.metadata!.keys.length != rawMetadata.keys.length) {
        log("Found discrepancy: raw metadata key count ${rawMetadata.keys
            .length} different from object metadata key count ${obj.data
            .metadata!.keys.length}");
        // This could be an additional check if required.
        // return !isValid;
      }
    } else {
      log(
          "found discrepancy: rawMetadata is not Map<Object?, Object?>. Found: ${rawMetadata
              .runtimeType}");
      return !isValid;
    }
    // If we reach here, and rawMetadata was not null, it means it was a map and all its keys matched.
    // However, if obj.data.metadata was null while rawMetadata was not, the loop logic for `obj.data.metadata![key]` would fail.
    // The check `obj.data.metadata == null` inside the loop handles this.
  } else if (obj.data.metadata != null && obj.data.metadata!.isNotEmpty) {
    // If rawMetadata is null, obj.data.metadata should also be null or empty.
    log(
        "found discrepancy: raw metadata is null, but obj metadata is not empty: ${obj
            .data.metadata}");
    return !isValid;
  }


  // Validate 'device' (optional field, a nested map).
  var validDevice = _validateDevice(rawDevice, obj);
  if (!validDevice) {
    // _validateDevice will log its own discrepancies.
    return !isValid;
  }

  // Validate 'sourceRevision' (optional field, a nested map).
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
        return !isValid;
      }
      // Check for key count differences if needed
      if (obj.data.sourceRevision != null &&
          obj.data.sourceRevision!.keys.length !=
              rawSourceRevision.keys.length) {
        log("Found discrepancy: raw sourceRevision key count ${rawSourceRevision
            .keys.length} different from object sourceRevision key count ${obj
            .data.sourceRevision!.keys.length}");
        // return !isValid;
      }
    } else {
      log(
          "found discrepancy: raw source revision is not Map<Object?, Object?>. Found: ${rawSourceRevision
              .runtimeType}");
      return !isValid;
    }
  } else
  if (obj.data.sourceRevision != null && obj.data.sourceRevision!.isNotEmpty) {
    log(
        "found discrepancy: raw source revision is null, but obj source revision is not empty: ${obj
            .data.sourceRevision}");
    return !isValid;
  }

  // --- Validation against OpenMHealth object (`openMHealth`) ---
  // This section ensures that the data, after being processed into HKHeartRate,
  // still holds true when converted to the OpenMHealth standard.

  // Assuming openMHealth list contains at least one element for a valid conversion.
  if (openMHealth.isEmpty) {
    log("found discrepancy: OpenMHealth conversion resulted in an empty list.");
    return !isValid;
  }
  var omhObj = openMHealth[0]; // Get the first (and likely only) OpenMHealth object.

  // Validate heart rate value consistency.
  if (omhObj.heartRate.value != obj.data.quantity.value) {
    log(
        "found discrepancy: obj quantity ${obj.data.quantity
            .value} - omh value ${omhObj.heartRate.value}");
    return !isValid;
  }

  // Validate effective time frame consistency (OpenMHealth dateTime vs. HKHeartRate startDate).
  // Ensure omhObj.effectiveTimeFrame.dateTime is not null before comparison.
  if (omhObj.effectiveTimeFrame.dateTime == null) {
    log("found discrepancy: OpenMHealth effectiveTimeFrame.dateTime is null.");
    return !isValid;
  }
  if (!omhObj.effectiveTimeFrame.dateTime!.isAtSameMomentAs(
      obj.data.startDate)) {
    log(
        "found discrepancy: obj startTime ${obj.data.startDate
            .toIso8601String()} - omh start date: ${omhObj.effectiveTimeFrame
            .dateTime!.toIso8601String()}");
    return !isValid;
  }

  // If all checks passed, the data is considered valid.
  return isValid; // Which will be true if no 'return !isValid' was hit.
}

/// Helper function to validate the 'quantity' field, which is a nested map
/// containing 'value' and 'unit' for the heart rate.
///
/// Parameters:
///  - [rawQuantity]: The raw 'quantity' map from the input data.
///  - [obj]: The instantiated [HKHeartRate] object containing the parsed quantity.
///
/// Returns:
///  - `true` if the value and unit in `rawQuantity` match those in `obj.data.quantity`.
///  - `false` otherwise, logging discrepancies.
bool _validateQuantity(dynamic rawQuantity, HKHeartRate obj) {
  var isValid = true; // Local validation flag for this specific function.
  if (rawQuantity is Map<Object?, Object?>) {
    // Check if 'value' key exists in rawQuantity.
    if (rawQuantity.containsKey("value")) {
      // Check if 'unit' key exists in rawQuantity.
      if (rawQuantity.containsKey("unit")) {
        // Compare 'value'.
        if (rawQuantity["value"] != obj.data.quantity.value) {
          log(
              "found discrepancy: raw quantity value: ${rawQuantity["value"]} - obj quantity value: ${obj
                  .data.quantity.value}");
          return !isValid; // Return false
        }
        // Compare 'unit'.
        if (rawQuantity["unit"] != obj.data.quantity.unit) {
          log(
              "found discrepancy: raw quantity unit: ${rawQuantity["unit"]} - obj quantity unit: ${obj
                  .data.quantity.unit}");
          return !isValid; // Return false
        }
      } else {
        log("found discrepancy: raw quantity did not contain key 'unit'");
        return !isValid; // Return false
      }
    } else {
      log("found discrepancy: raw quantity did not contain key 'value'");
      return !isValid; // Return false
    }
  } else {
    log(
        "found discrepancy: raw quantity is not a Map<Object?, Object?>. Found: ${rawQuantity
            .runtimeType}");
    return !isValid; // Return false
  }
  return isValid; // Return true if all checks passed
}

/// Helper function to validate the 'device' field, which can be a nested map
/// containing device information like name, manufacturer, model, etc.
///
/// Parameters:
///  - [rawDevice]: The raw 'device' map from the input data. Can be null.
///  - [obj]: The instantiated [HKHeartRate] object containing the parsed device info.
///
/// Returns:
///  - `true` if all present fields in `rawDevice` match those in `obj.data.device`,
///    or if both are null/empty appropriately.
///  - `false` otherwise, logging discrepancies.
bool _validateDevice(dynamic rawDevice, HKHeartRate obj) {
  var isValid = true; // Local validation flag.

  // If rawDevice is present, then obj.data.device should also be present and match.
  if (rawDevice != null) {
    if (obj.data.device == null) {
      log("found discrepancy: raw device is present but obj device is null.");
      return !isValid; // Return false
    }
    if (rawDevice is Map<Object?, Object?>) {
      // Extract specific fields from rawDevice for comparison.
      var rawDeviceName = rawDevice["name"];
      var rawDeviceManufacturer = rawDevice["manufacturer"];
      var rawDeviceModel = rawDevice["model"];
      // Typo in original rawData key: "hardwareVerison", should match whatever HealthKit sends.
      // Corrected to "hardwareVersion" in comment, assuming obj.data.device.hardwareVersion is the correct field name.
      // If HealthKit *actually* sends "hardwareVerison", then rawDevice["hardwareVerison"] is correct for lookup.
      var rawDeviceHardwareVersion = rawDevice["hardwareVersion"] ??
          rawDevice["hardwareVerison"]; // Handle potential typo gracefully
      var rawDeviceSoftwareVersion = rawDevice["softwareVersion"];

      // Compare 'name', if present in rawDevice.
      if (rawDeviceName != null) {
        if (rawDeviceName != obj.data.device!.name) {
          log(
              "found discrepancy: raw device name $rawDeviceName - obj device name ${obj
                  .data.device!.name}");
          return !isValid;
        }
      } else if (obj.data.device!.name != null) {
        log(
            "found discrepancy: raw device name is null, but obj device name is ${obj
                .data.device!.name}");
        return !isValid;
      }

      // Compare 'manufacturer', if present in rawDevice.
      if (rawDeviceManufacturer != null) {
        if (rawDeviceManufacturer != obj.data.device!.manufacturer) {
          log(
              "found discrepancy: raw device manufacturer: $rawDeviceManufacturer - obj device manufacturer ${obj
                  .data.device!.manufacturer}");
          return !isValid;
        }
      } else if (obj.data.device!.manufacturer != null) {
        log(
            "found discrepancy: raw device manufacturer is null, but obj device manufacturer is ${obj
                .data.device!.manufacturer}");
        return !isValid;
      }

      // Compare 'model', if present in rawDevice.
      if (rawDeviceModel != null) {
        if (rawDeviceModel != obj.data.device!.model) {
          log(
              "found discrepancy: raw device model $rawDeviceModel - obj device model ${obj
                  .data.device!
                  .model}"); // Typo "deviced" corrected to "device"
          return !isValid;
        }
      } else if (obj.data.device!.model != null) {
        log(
            "found discrepancy: raw device model is null, but obj device model is ${obj
                .data.device!.model}");
        return !isValid;
      }

      // Compare 'hardwareVersion', if present in rawDevice.
      if (rawDeviceHardwareVersion != null) {
        if (rawDeviceHardwareVersion != obj.data.device!.hardwareVersion) {
          log(
              "found discrepancy: raw device hardware version $rawDeviceHardwareVersion - obj device hardware version ${obj
                  .data.device!.hardwareVersion}");
          return !isValid;
        }
      } else if (obj.data.device!.hardwareVersion != null) {
        log(
            "found discrepancy: raw device hardware version is null, but obj device hardware version is ${obj
                .data.device!.hardwareVersion}");
        return !isValid;
      }

      // Compare 'softwareVersion', if present in rawDevice.
      if (rawDeviceSoftwareVersion != null) {
        if (rawDeviceSoftwareVersion != obj.data.device!.softwareVersion) {
          log(
              "found discrepancy: raw device software version $rawDeviceSoftwareVersion - obj device software version ${obj
                  .data.device!.softwareVersion}");
          return !isValid;
        }
      } else if (obj.data.device!.softwareVersion != null) {
        log(
            "found discrepancy: raw device software version is null, but obj device software version is ${obj
                .data.device!.softwareVersion}");
        return !isValid;
      }
    } else {
      log(
          "found discrepancy: raw device is not Map<Object?, Object?>. Found: ${rawDevice
              .runtimeType}");
      return !isValid; // Return false
    }
  }
  // If rawDevice is null, then obj.data.device should also be null.
  else if (obj.data.device != null) {
    log(
        "found discrepancy: raw device is null, but obj device is not null: ${obj
            .data.device}");
    return !isValid; // Return false
  }
  return isValid; // Return true if all checks passed or both were appropriately null.
}