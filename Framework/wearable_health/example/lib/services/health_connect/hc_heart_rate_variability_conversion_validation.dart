import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health_example/services/health_connect/hc_metadata_conversion_validation.dart';

/// Validates the conversion of raw Heart Rate Variability (HRV) data into a
/// [HealthConnectHeartRateVariabilityRmssd] object and its subsequent transformation
/// into an OpenMHealth HRV schema.
///
/// This function performs a series of checks:
/// 1.  Attempts to create a [HealthConnectHeartRateVariabilityRmssd] object from [rawData]
///     using the provided [hcFactory].
/// 2.  Converts this object to its OpenMHealth representation.
/// 3.  Compares fields from the original [rawData] (time, zone offset, HRV value)
///     against the corresponding fields in the created [HealthConnectHeartRateVariabilityRmssd] object.
/// 4.  Validates the metadata conversion using [isValidHCMetaData].
/// 5.  Checks the integrity and correctness of the converted OpenMHealth HRV data,
///     including algorithm type, value consistency, and time frame.
///
/// Logs discrepancies found during validation and returns `false` immediately if any check fails.
///
/// Parameters:
///  - [rawData]: A map containing the raw HRV data. Expected keys include "timeEpochMs",
///    "zoneOffsetSeconds", "heartRateVariabilityMillis", and "metadata".
///  - [hcFactory]: An instance of [HCDataFactory] used to create the
///    [HealthConnectHeartRateVariabilityRmssd] object.
///
/// Returns:
///  - `true` if all conversion and data integrity checks pass, `false` otherwise.
bool isValidHCHeartRateVariabilityConversion(Map<String, dynamic> rawData,
    HCDataFactory hcFactory,) {
  // var isValid = true; // This flag becomes redundant if we return false directly on errors.

  // Step 1 & 2: Create Health Connect object and convert to OpenMHealth.
  var obj = hcFactory.createHeartRateVariability(rawData);
  var omhObjList = obj
      .toOpenMHealthHeartRateVariabilityRmssd(); // Assuming this returns a list

  // Extract raw values for comparison.
  var rawTimeEpochMs = rawData["timeEpochMs"];
  var rawZoneOffsetSeconds = rawData["zoneOffsetSeconds"];
  var rawHeartRateVariabilityMillis = rawData["heartRateVariabilityMillis"];

  // Step 3: Validate raw data against the created Health Connect object.

  // Validate time.
  // Ensure rawTimeEpochMs is not null before using it.
  if (rawTimeEpochMs == null || rawTimeEpochMs is! int) {
    log(
        "Discrepancy found: raw timeEpochMs is null or not an integer: $rawTimeEpochMs");
    return false;
  }
  if (!DateTime.fromMillisecondsSinceEpoch(
    rawTimeEpochMs,
  ).isAtSameMomentAs(obj.time)) {
    log("Discrepancy found: raw time epoch ms: $rawTimeEpochMs - obj time: ${obj
        .time}");
    return false;
  }

  // Validate zone offset, if present in raw data.
  if (rawZoneOffsetSeconds != null) {
    if (rawZoneOffsetSeconds is! int) {
      log(
          "Discrepancy found: raw zoneOffsetSeconds is not an integer: $rawZoneOffsetSeconds");
      return false;
    }
    if (rawZoneOffsetSeconds != obj
        .zoneOffset) { // Assuming obj.zoneOffset can be null if rawZoneOffsetSeconds is null
      log(
        "Discrepancy found: raw zone offset seconds: $rawZoneOffsetSeconds - obj zone offset seconds: ${obj
            .zoneOffset}",
      );
      return false;
    }
  } else if (obj.zoneOffset != null) {
    // If rawZoneOffsetSeconds is null, obj.zoneOffset should also ideally be null or not set.
    log(
        "Discrepancy found: raw zoneOffsetSeconds is null, but obj zone offset seconds is: ${obj
            .zoneOffset}");
    return false;
  }


  // Validate HRV value.
  // Ensure rawHeartRateVariabilityMillis is not null and is a number before using it.
  if (rawHeartRateVariabilityMillis == null ||
      rawHeartRateVariabilityMillis is! num) {
    log(
        "Discrepancy found: raw heartRateVariabilityMillis is null or not a number: $rawHeartRateVariabilityMillis");
    return false;
  }
  if (rawHeartRateVariabilityMillis.toDouble() !=
      obj.heartRateVariabilityMillis) { // Ensure comparison is double vs double
    log(
      "Discrepancy found: raw hrv/ms: $rawHeartRateVariabilityMillis - obj hrv/ms ${obj
          .heartRateVariabilityMillis}",
    );
    return false;
  }

  // Step 4: Validate metadata.
  Map<String, dynamic> rawMetadata = {};
  // Check if rawData["metadata"] exists and is a Map.
  if (rawData["metadata"] != null && rawData["metadata"] is Map) {
    // Using a for-in loop for entries for safer key processing.
    for (var entry in (rawData["metadata"] as Map).entries) {
      if (entry.key is String) {
        rawMetadata[entry.key as String] = entry.value;
      } else {
        log("Raw metadata had non-string key: ${entry
            .key}. This key will be skipped in validation against object metadata.");
        // Depending on requirements, a non-string key in raw metadata might be a validation failure.
        // For now, it's logged, and the key is skipped. If this should fail, add 'return false;'
      }
    }
  } else if (rawData["metadata"] != null) {
    log("Raw metadata was not a Map. Got: ${rawData["metadata"].runtimeType}");
    // Depending on strictness, you might 'return false;' here.
    // If metadata is mandatory and of the wrong type, it's a failure.
    // If it's optional, isValidHCMetaData will handle an empty rawMetadata map if obj.metadata is also empty/default.
  }
  // If rawData["metadata"] is null, rawMetadata will be empty, which is fine if obj.metadata is also empty/default.

  if (!isValidHCMetaData(rawMetadata, obj.metadata)) {
    // isValidHCMetaData will log its own discrepancies.
    return false;
  }

  // Step 5: Validate OpenMHealth data.
  if (omhObjList.length != 1) {
    log(
      "Discrepancy found: OpenMHealth list did not contain exactly one element. Found ${omhObjList
          .length} records.",
    );
    return false;
  }

  var omhHrv = omhObjList[0]; // Get the single OpenMHealth HRV object.

  // Validate algorithm type.
  if (omhHrv.algorithm != HrvAlgorithm.rmssd) {
    log(
      "Discrepancy found: OpenMHealth heart rate variability has wrong algorithm type. Expected RMSSD. Found: ${omhHrv
          .algorithm}",
    );
    return false;
  }

  // Validate HRV value consistency between Health Connect object and OpenMHealth object.
  if (omhHrv.heartRateVariability.value != obj.heartRateVariabilityMillis) {
    log(
      "Discrepancy found: HC obj HRV (ms): ${obj
          .heartRateVariabilityMillis} - OMH HRV value: ${omhHrv
          .heartRateVariability.value}",
    );
    return false;
  }

  // Validate time consistency.
  // Ensure effectiveTimeFrame and dateTime are not null before accessing.
  if (omhHrv.effectiveTimeFrame.dateTime == null) {
    log("Discrepancy found: OpenMHealth effectiveTimeFrame.dateTime is null.");
    return false;
  }
  if (!omhHrv.effectiveTimeFrame.dateTime!.isAtSameMomentAs(obj.time)) {
    log(
      "Discrepancy found: HC object time: ${obj.time
          .toString()} - OMH effective time: ${omhHrv.effectiveTimeFrame
          .dateTime!.toString()}",
    );
    // The original code was missing 'return false;' here if a discrepancy was found.
    return false;
  }

  // If all checks passed, the conversion is considered valid.
  return true; // Changed from 'return isValid;'
}