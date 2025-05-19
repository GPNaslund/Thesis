import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health_example/hc_metadata_conversion_validation.dart';

bool isValidHeartRateVariabilityConversion(
  Map<String, dynamic> rawData,
  HCDataFactory hcFactory,
) {
  var isValid = true;

  var obj = hcFactory.createHeartRateVariability(rawData);
  var omhObj = obj.toOpenMHealthHeartRateVariabilityRmssd();

  // Extract raw values
  var rawTimeEpochMs = rawData["timeEpochMs"];
  var rawZoneOffsetSeconds = rawData["zoneOffsetSeconds"];
  var rawHeartRateVariabilityMillis = rawData["heartRateVariabilityMillis"];

  // Validate raw to object data
  if (!DateTime.fromMillisecondsSinceEpoch(
    rawTimeEpochMs,
  ).isAtSameMomentAs(obj.time)) {
    log("discrepancy found: raw time epoch ms: $rawTimeEpochMs - obj time");
    return !isValid;
  }

  if (rawZoneOffsetSeconds != null && rawZoneOffsetSeconds != obj.zoneOffset!) {
    log(
      "discrepancy found: raw zone offset seconds: $rawZoneOffsetSeconds - obj zone offset seconds: ${obj.zoneOffset}",
    );
    return !isValid;
  }

  if (rawHeartRateVariabilityMillis != obj.heartRateVariabilityMillis) {
    log(
      "discrepancy found: raw hrv/ms: $rawHeartRateVariabilityMillis - obj hrv/ms ${obj.heartRateVariabilityMillis}",
    );
    return !isValid;
  }

  if (!validateMetaData(rawData["metadata"], obj.metadata)) {
    return !isValid;
  }

  // Validate obj to open m health data
  if (omhObj.length != 1) {
    log(
      "discrepancy found: open m health did not contain only one element. Found ${omhObj.length} amount of records",
    );
    return !isValid;
  }

  var omhHrv = omhObj[0];

  if (omhHrv.algorithm != HrvAlgorithm.rmssd) {
    log(
      "discrepancy found: open m health heart rate variability has wrong algorithm type. Found: ${omhHrv.algorithm}",
    );
    return !isValid;
  }

  if (omhHrv.heartRateVariability.value != obj.heartRateVariabilityMillis) {
    log(
      "discrepancy found: hrv obj heart rate variability: ${obj.heartRateVariabilityMillis} - open m health heart rate variability: ${omhHrv.heartRateVariability.value}",
    );
    return !isValid;
  }

  if (!omhHrv.effectiveTimeFrame.dateTime!.isAtSameMomentAs(obj.time)) {
    log(
      "discrepancy found: hrv object time: ${obj.time.toString()} - open m health time: ${omhHrv.effectiveTimeFrame.dateTime!.toString()}",
    );
  }

  return isValid;
}
