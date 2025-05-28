import 'dart:developer';

import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';

/// Validates if the fields of a raw metadata map (`rawData`) match the corresponding
/// fields of a [HealthConnectMetadata] object (`metadata`).
///
/// This function performs a field-by-field comparison between the raw data
/// (expected to be sourced from a format like JSON) and the structured
/// [HealthConnectMetadata] object. It checks for discrepancies in:
///  - `dataOrigin`
///  - `id`
///  - `lastModifiedTime` (parsed and compared as [DateTime] objects)
///  - `recordingMethod`
///  - `clientRecordId` (if present in `rawData`)
///  - `clientRecordVersion` (if present in `rawData`)
///  - `device` (if present in `rawData`)
///
/// If any discrepancy is found, a message is logged to the console, and
/// the function immediately returns `false`.
///
/// Parameters:
///  - [rawData]: A `Map<String, dynamic>` containing the raw metadata fields.
///    Keys are expected to match the property names in [HealthConnectMetadata].
///  - [metadata]: The [HealthConnectMetadata] object to compare against.
///
/// Returns:
///  - `true` if all checked fields in `rawData` match the corresponding fields
///    in the `metadata` object, `false` otherwise.
bool isValidHCMetaData(Map<String, dynamic> rawData,
    HealthConnectMetadata metadata,) {
  // var isValid = true; // Flag is redundant due to immediate returns on failure.

  // Validate 'dataOrigin'.
  if (rawData["dataOrigin"] != metadata.dataOrigin) {
    log(
      "Found discrepancy: raw metadata data origin: ${rawData["dataOrigin"]} - obj metadata data origin: ${metadata
          .dataOrigin}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // Validate 'id'.
  if (rawData["id"] != metadata.id) {
    log(
      "Found discrepancy: raw metadata data id: ${rawData["id"]} - obj metadata id: ${metadata
          .id}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // Validate 'lastModifiedTime'.
  // Ensure 'lastModifiedTime' exists and is a String in rawData before parsing.
  if (rawData["lastModifiedTime"] == null ||
      rawData["lastModifiedTime"] is! String) {
    log(
      "Found discrepancy: raw metadata lastModifiedTime is null or not a String: ${rawData["lastModifiedTime"]}",
    );
    return false; // Invalid format or missing, validation fails.
  }
  try {
    if (!DateTime.parse(
      rawData["lastModifiedTime"],
    ).isAtSameMomentAs(metadata.lastModifiedTime)) {
      log(
        "Found discrepancy: raw metadata last modified time: ${rawData["lastModifiedTime"]} - obj metadata lastModifiedTime ${metadata
            .lastModifiedTime}",
      );
      return false; // Discrepancy found, validation fails.
    }
  } catch (e) {
    log(
        "Error parsing raw metadata lastModifiedTime '${rawData["lastModifiedTime"]}': $e");
    return false; // Parsing error, validation fails.
  }


  // Validate 'recordingMethod'.
  // Ensure 'recordingMethod' exists in rawData before comparison.
  // metadata.recordingMethod is an enum, so rawData["recordingMethod"] should match its expected string representation or integer value if applicable.
  // Assuming HealthConnectMetadata.recordingMethod is an int as per typical Health Connect SDKs.
  // If it's a String or an enum that serializes to String, adjust the check accordingly.
  if (rawData["recordingMethod"] == null) {
    log(
        "Found discrepancy: raw metadata recordingMethod is null, but object metadata has: ${metadata
            .recordingMethod}");
    return false;
  }
  // This comparison assumes metadata.recordingMethod is an int.
  // If metadata.recordingMethod is an enum that serializes to its .name or a custom string,
  // the comparison needs to be rawData["recordingMethod"] != metadata.recordingMethod.toStringValue() or similar.
  // For now, let's assume it's an int and rawData holds an int.
  if (rawData["recordingMethod"] is! int &&
      metadata.recordingMethod is int) { // Check types if expecting int
    log(
        "Found discrepancy: raw metadata recordingMethod type mismatch. Expected int, got ${rawData["recordingMethod"]
            .runtimeType}");
    return false;
  }
  if (rawData["recordingMethod"] != metadata.recordingMethod) {
    log(
      "Found discrepancy: raw metadata recording method: ${rawData["recordingMethod"]} - obj metadata recording method ${metadata
          .recordingMethod}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // Validate 'clientRecordId', if present in rawData.
  if (rawData["clientRecordId"] != null &&
      rawData["clientRecordId"] != metadata.clientRecordId) {
    log(
      "Found discrepancy: raw metadata client record id: ${rawData["clientRecordId"]} - obj metadata client record id ${metadata
          .clientRecordId}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // Validate 'clientRecordVersion', if present in rawData.
  if (rawData["clientRecordVersion"] != null &&
      rawData["clientRecordVersion"] != metadata.clientRecordVersion) {
    log(
      "Found discrepancy: raw metadata client record version: ${rawData["clientRecordVersion"]} - obj metadata client record version ${metadata
          .clientRecordVersion}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // Validate 'device', if present in rawData.
  // Note: 'device' in HealthConnectMetadata is often an object itself (e.g., Device object).
  // This comparison `rawData["device"] != metadata.device` assumes that:
  // 1. If rawData["device"] is present, it's directly comparable to metadata.device.
  // 2. This might mean rawData["device"] is also a HealthConnect Device object or a compatible Map.
  // If rawData["device"] is a Map and metadata.device is an object, a more detailed field-by-field comparison
  // or a .toJson()/.equals() method on the Device object would be needed for accurate validation.
  // For simplicity, sticking to the direct comparison as in the original code.
  if (rawData["device"] != null && rawData["device"] != metadata.device) {
    log(
      "Found discrepancy: raw metadata device: ${rawData["device"]} - obj metadata device ${metadata
          .device}",
    );
    return false; // Discrepancy found, validation fails.
  }

  // If all checks passed without returning false, the metadata is considered valid.
  return true; // Changed from 'return isValid;'
}