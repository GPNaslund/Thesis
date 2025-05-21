import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/services/health_connect/hc_metadata_conversion_validation.dart';

bool isValidHCHeartRateConversion(
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

  List<Object?> rawSamples = rawData["samples"];

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

  if (rawStartZoneOffsetSeconds != null) {
    if (rawStartZoneOffsetSeconds != obj.endZoneOffset) {
      log(
        "Found discrepancy: raw start zone offset: $rawStartZoneOffsetSeconds - ${obj.startZoneOffset}",
      );
      return !isValid;
    }
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
    Map<String, dynamic> rawSampleMap = {};

    if (rawSample is Map<Object?, Object?>) {
      rawSample.forEach((key, value) {
        if (key is String) {
          rawSampleMap[key] = value;
        } else {
          log("found discrepancy: raw sample had non string key: $key, with type: ${key.runtimeType}");
          !isValid;
        }
      });
    } else {
      log("found discrepancy: raw sample is not a map. Got: ${rawSample.runtimeType}");
      return !isValid;
    }

    var objSample = obj.samples[i];

    if (!DateTime.parse(rawSampleMap["time"]).isAtSameMomentAs(objSample.time)) {
      log(
        "Found discrepancy: raw sample time: ${rawSampleMap["time"]} - obj sample time: ${objSample.time}",
      );
      return !isValid;
    }

    if (rawSampleMap["beatsPerMinute"] != objSample.beatsPerMinute) {
      log(
        "Found discrepancy: raw beats per minute: ${rawSampleMap["beatsPerMinute"]} - obj beats per minute: ${objSample.beatsPerMinute}",
      );
      return !isValid;
    }
  }

  Map<String, dynamic> rawMetadata = {};
  rawData["metadata"].forEach((key, value) {
    if (key is String) {
      rawMetadata[key] = value;
    } else {
      log("raw metadata had non string key: $key");
    }
  });

  if (!isValidHCMetaData(rawMetadata, obj.metadata)) {
    return !isValid;
  }


  for (var i = 0; i < obj.samples.length; i++) {
    var objSample = obj.samples[i];
    var omhObj = openMHealth[i];

    if (objSample.beatsPerMinute != omhObj.heartRate.value) {
      log(
        "Found discrepancy: obj sample beats per minute: ${objSample.beatsPerMinute} - open m health heart rate value: ${omhObj.heartRate.value}",
      );
      return !isValid;
    }

    if (!objSample.time.isAtSameMomentAs(omhObj.effectiveTimeFrame.timeInterval!.startDateTime!)) {
      log(
        "Found discrepancy: obj sample time: ${objSample.time.toString()} - open m health effective time frame: ${omhObj.effectiveTimeFrame.dateTime!.toString()}",
      );
      return !isValid;
    }
  }

  return isValid;
}
