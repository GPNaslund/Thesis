import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/hc_metadata_conversion_validation.dart';

bool isValidHeartRateConversion(
  Map<String, dynamic> rawData,
  HCDataFactory hcDataFactory,
) {
  var isValid = true;
  var obj = hcDataFactory.createHeartRate(rawData);
  var openMHealth = obj.toOpenMHealthHeartRate();

  // Raw values
  var rawStartDate = DateTime.fromMillisecondsSinceEpoch(
    rawData["startTimeEpochMs"],
  );
  var rawEndDate = DateTime.fromMillisecondsSinceEpoch(
    rawData["endTimeEpochMs"],
  );

  int? rawStartZoneOffsetSeconds = rawData["startZoneOffsetSeconds"];
  int? rawEndZoneOffsetSeconds = rawData["endZoneOffsetSeconds"];

  List<Map<String, dynamic>> rawSamples = rawData["samples"];

  // Validate raw object against created object
  if (!rawStartDate.isAtSameMomentAs(obj.startTime)) {
    log(
      "Found discrepancy: raw start date: ${rawStartDate.toString()} - ${obj.startTime.toString()}",
    );
    return !isValid;
  }

  if (!rawEndDate.isAtSameMomentAs(obj.endTime)) {
    log(
      "Found discepancy: raw end date: ${rawEndDate.toString()} - ${obj.endTime.toString()}",
    );
    return !isValid;
  }

  if (rawStartZoneOffsetSeconds != null &&
      rawStartZoneOffsetSeconds != obj.startZoneOffset!) {
    log(
      "Found discrepancy: raw start zone offset: $rawStartZoneOffsetSeconds - ${obj.startZoneOffset}",
    );
    return !isValid;
  }

  if (rawEndZoneOffsetSeconds != null &&
      rawEndZoneOffsetSeconds != obj.endZoneOffset!) {
    log(
      "Found discrepancy: raw end zone offset: $rawEndZoneOffsetSeconds - ${obj.endZoneOffset}",
    );
    return !isValid;
  }

  for (var i = 0; i < rawSamples.length; i++) {
    var rawSample = rawSamples[i];
    var objSample = obj.samples[i];

    if (DateTime.parse(rawSample["time"]).isAtSameMomentAs(objSample.time)) {
      log(
        "Found discrepancy: raw sample time: ${rawSample["time"]} - obj sample time: ${objSample.time}",
      );
      return !isValid;
    }

    if (rawSample["beatsPerMinute"] != objSample.beatsPerMinute) {
      log(
        "Found discrepancy: raw beats per minute: ${rawSample["beatsPerMinute"]} - obj beats per minute: ${objSample.beatsPerMinute}",
      );
      return !isValid;
    }
  }

  if (!validateMetaData(rawData["metadata"], obj.metadata)) {
    return !isValid;
  }

  // Validate open mhealth conversion

  for (var i = 0; i < obj.samples.length; i++) {
    var objSample = obj.samples[i];
    var omhObj = openMHealth[i];

    if (objSample.beatsPerMinute != omhObj.heartRate.value) {
      log(
        "Found discrepancy: obj sample beats per minute: ${objSample.beatsPerMinute} - open m health heart rate value: ${omhObj.heartRate.value}",
      );
      return !isValid;
    }

    if (!objSample.time.isAtSameMomentAs(omhObj.effectiveTimeFrame.dateTime!)) {
      log(
        "Found discrepancy: obj sample time: ${objSample.time.toString()} - open m health effective time frame: ${omhObj.effectiveTimeFrame.dateTime!.toString()}",
      );
      return !isValid;
    }
  }

  return isValid;
}
