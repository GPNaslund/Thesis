import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/services/health_connect/hc_metadata_conversion_validation.dart';

/// Validates the conversion of raw heart rate data into a [HealthConnectHeartRate] object
/// and its subsequent transformation into an OpenMHealth heart rate schema.
///
/// This function performs a series of checks:
/// 1.  Attempts to create a [HealthConnectHeartRate] object from the [rawData] using the provided [hcDataFactory].
/// 2.  Converts this [HealthConnectHeartRate] object to an OpenMHealth heart rate representation.
/// 3.  Compares fields from the original [rawData] (like start/end times, zone offsets, and samples)
///     against the corresponding fields in the created [HealthConnectHeartRate] object.
/// 4.  Validates the metadata conversion using [isValidHCMetaData].
/// 5.  Compares fields from the [HealthConnectHeartRate] object's samples against the
///     corresponding fields in the OpenMHealth representation.
///
/// Logs discrepancies found during validation and returns `false` immediately if any check fails.
///
/// Parameters:
///  - [rawData]: A map containing the raw heart rate data to be validated. Expected to have keys like
///    "startTimeEpochMs", "endTimeEpochMs", "startZoneOffsetSeconds", "endZoneOffsetSeconds", "samples", and "metadata".
///  - [hcDataFactory]: An instance of [HCDataFactory] used to create the [HealthConnectHeartRate] object.
///
/// Returns:
///  - `true` if all conversion and data integrity checks pass, `false` otherwise.
bool isValidHCHeartRateConversion(Map<String, dynamic> rawData,
    HCDataFactory hcDataFactory,) {
  var isValid = true; // Flag to track validation status, initially true.

  // Step 1: Create HealthConnectHeartRate object from raw data.
  var obj = hcDataFactory.createHeartRate(rawData);
  // Step 2: Convert to OpenMHealth format.
  var openMHealth = obj.toOpenMHealthHeartRate();

  // Extract raw values for comparison.
  var rawStartDate = DateTime.fromMillisecondsSinceEpoch(
    rawData["startTimeEpochMs"],
  );
  var rawEndDate = DateTime.fromMillisecondsSinceEpoch(
    rawData["endTimeEpochMs"],
  );

  int? rawStartZoneOffsetSeconds = rawData["startZoneOffsetSeconds"];
  int? rawEndZoneOffsetSeconds = rawData["endZoneOffsetSeconds"];

  List<Object?> rawSamples = rawData["samples"];

  // Step 3: Validate raw object against created HealthConnectHeartRate object.

  // Validate start time.
  if (!rawStartDate.isAtSameMomentAs(obj.startTime)) {
    log(
      "Found discrepancy: raw start date: ${rawStartDate
          .toString()} - HealthConnect object start time: ${obj.startTime
          .toString()}",
    );
    return !isValid; // Equivalent to return false
  }

  // Validate end time.
  if (!rawEndDate.isAtSameMomentAs(obj.endTime)) {
    log(
      "Found discrepancy: raw end date: ${rawEndDate
          .toString()} - HealthConnect object end time: ${obj.endTime
          .toString()}",
    );
    return !isValid;
  }

  // Validate start zone offset, if present in raw data.
  if (rawStartZoneOffsetSeconds != null) {
    if (rawStartZoneOffsetSeconds != obj
        .startZoneOffset) { // Note: Original code compared rawStartZoneOffsetSeconds to obj.endZoneOffset. Assuming obj.startZoneOffset was intended.
      log(
        "Found discrepancy: raw start zone offset: $rawStartZoneOffsetSeconds - HealthConnect object start zone offset: ${obj
            .startZoneOffset}",
      );
      return !isValid;
    }
  }

  // Validate end zone offset, if present in raw data.
  if (rawEndZoneOffsetSeconds != null &&
      rawEndZoneOffsetSeconds != obj.endZoneOffset!) {
    log(
      "Found discrepancy: raw end zone offset: $rawEndZoneOffsetSeconds - HealthConnect object end zone offset: ${obj
          .endZoneOffset}",
    );
    return !isValid;
  }

  // Validate individual samples.
  // Using a standard for loop to allow early return from the outer function.
  for (var i = 0; i < rawSamples.length; i++) {
    var rawSample = rawSamples[i];
    Map<String, dynamic> rawSampleMap = {};

    // Ensure the raw sample is a Map and convert its keys to String if necessary.
    if (rawSample is Map<Object?, Object?>) {
      // It's safer to build the map and then check for errors,
      // or to return immediately if a non-string key is found.
      // Let's iterate through keys and build rawSampleMap.
      // If a non-string key is found, we log and return false.
      for (var entry in rawSample.entries) {
        if (entry.key is String) {
          rawSampleMap[entry.key as String] = entry.value;
        } else {
          log(
              "Found discrepancy: raw sample had non-string key: ${entry.key}, with type: ${entry.key.runtimeType}");
          return false; // Exit isValidHCHeartRateConversion immediately
        }
      }
    } else {
      log("Found discrepancy: raw sample is not a map. Got: ${rawSample.runtimeType}");
      return false; // Sample type mismatch is a validation failure. Exit.
    }

    var objSample = obj.samples[i]; // Corresponding sample from the HealthConnect object.

    // Validate sample time.
    if (!DateTime.parse(rawSampleMap["time"] as String).isAtSameMomentAs(objSample.time)) { // Added 'as String' for safety
      log(
        "Found discrepancy: raw sample time: ${rawSampleMap["time"]} - HealthConnect object sample time: ${objSample.time}",
      );
      return false;
    }

    // Validate sample beats per minute.
    if (rawSampleMap["beatsPerMinute"] != objSample.beatsPerMinute) {
      log(
        "Found discrepancy: raw beats per minute: ${rawSampleMap["beatsPerMinute"]} - HealthConnect object beats per minute: ${objSample.beatsPerMinute}",
      );
      return false;
    }
  }

  // Step 4: Validate metadata.
  Map<String, dynamic> rawMetadata = {};
  // Ensure raw metadata keys are strings.
  // Using a for-in loop for entries for safer key processing
  if (rawData["metadata"] is Map<dynamic, dynamic>) {
    for (var entry in (rawData["metadata"] as Map<dynamic, dynamic>).entries) {
      if (entry.key is String) {
        rawMetadata[entry.key as String] = entry.value;
      } else {
        log(
            "Raw metadata had non-string key: ${entry.key}. This key will be skipped in validation against object metadata.");
        // As per previous logic, not returning false here, just skipping.
      }
    }
  } else if (rawData["metadata"] != null) {
    log("Raw metadata was not a Map. Got: ${rawData["metadata"].runtimeType}");
    // Depending on requirements, you might want to return false here.
    // For now, it will proceed, and isValidHCMetaData might fail.
  }


  if (!isValidHCMetaData(rawMetadata, obj.metadata)) {
    // isValidHCMetaData will log its own discrepancies.
    return false;
  }

  // Step 5: Validate HealthConnect object samples against OpenMHealth representation.
  for (var i = 0; i < obj.samples.length; i++) {
    var objSample = obj.samples[i];
    var omhObj = openMHealth[i]; // Corresponding OpenMHealth object for the sample.

    // Validate beats per minute consistency.
    if (objSample.beatsPerMinute != omhObj.heartRate.value) {
      log(
        "Found discrepancy: HealthConnect sample beats per minute: ${objSample
            .beatsPerMinute} - OpenMHealth heart rate value: ${omhObj.heartRate
            .value}",
      );
      return !isValid;
    }

    // Validate time consistency (comparing HealthConnect sample time with OpenMHealth effective time frame start).
    if (objSample.time.isAtSameMomentAs(omhObj.effectiveTimeFrame
        .dateTime!)) { // Note: Original used omhObj.effectiveTimeFrame.timeInterval!.startDateTime!
      // Switched to .dateTime for direct comparison if timeInterval is not guaranteed.
      // If timeInterval is always present and startDateTime is desired, revert this.
      // Ensure the OpenMHealth object structure matches this access pattern.
      log(
        "Found discrepancy: HealthConnect sample time: ${objSample.time
            .toString()} - OpenMHealth effective time: ${omhObj
            .effectiveTimeFrame.dateTime!.toString()}",
      );
      return !isValid;
    }
  }

  // If all checks passed, the conversion is considered valid.
  return isValid;
}