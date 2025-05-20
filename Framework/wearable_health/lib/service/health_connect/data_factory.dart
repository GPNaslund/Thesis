import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_record_sample.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature_delta.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature_delta.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';

/// Implementation of HCDataFactory that creates Health Connect (Android)
/// data objects from JSON map structures.
class HCDataFactoryImpl implements HCDataFactory {
  /// JSON converter for safe type extraction.
  JsonConverter converter;

  /// Creates a new factory with the specified JSON converter.
  HCDataFactoryImpl(this.converter);

  /// Creates a HealthConnectHeartRate object from JSON map data.
  /// Extracts and validates all required fields, handling time conversions
  /// and sample collection.
  @override
  HealthConnectHeartRate createHeartRate(Map<String, dynamic> data) {
    var errMsg =
        "Error occured when extracting data for health connect heart rate";
    var startTime = converter.extractDateTimeFromEpochMs(
      data["startTimeEpochMs"],
      errMsg,
    );
    var endTime = converter.extractDateTimeFromEpochMs(
      data["endTimeEpochMs"],
      errMsg,
    );

    var startZoneOffset =
        data["startZoneOffsetSeconds"] != null
            ? converter.extractIntValue(data["startZoneOffsetSeconds"], errMsg)
            : null;

    var endZoneOffset =
        data["endZoneOffsetSeconds"] != null
            ? converter.extractIntValue(data["endZoneOffsetSeconds"], errMsg)
            : null;

    var samplesDataList = converter.extractList(data["samples"], errMsg);
    List<HeartRateRecordSample> samples = [];
    for (var sample in samplesDataList) {
      var samplesMap = converter.extractJsonObject(sample, errMsg);
      var time = converter.extractDateTime(samplesMap["time"], errMsg);
      var beatsPerMinute = converter.extractIntValue(
        samplesMap["beatsPerMinute"],
        errMsg,
      );
      var heartRateRecordSample = HeartRateRecordSample(time, beatsPerMinute);
      samples.add(heartRateRecordSample);
    }

    var metadataMap = converter.extractJsonObject(data["metadata"], errMsg);
    var metadata = _extractMetaData(metadataMap, errMsg);

    return HealthConnectHeartRate(
      startTime: startTime,
      endTime: endTime,
      startZoneOffset: startZoneOffset,
      endZoneOffset: endZoneOffset,
      samples: samples,
      metadata: metadata,
    );
  }

  /// Creates a HealthConnectSkinTemperature object from JSON map data.
  /// Extracts temperature baseline, delta measurements, and metadata.
  @override
  HealthConnectSkinTemperature createSkinTemperature(
    Map<String, dynamic> data,
  ) {
    var errMsg =
        "Error occured when extracting data for health connect skin temperature";
    var startTime = converter.extractDateTimeFromEpochMs(
      data["startTimeEpochMs"],
      errMsg,
    );
    var endTime = converter.extractDateTimeFromEpochMs(
      data["endTimeEpochMs"],
      errMsg,
    );
    var startZoneOffset =
        data["startZoneOffsetSeconds"] != null
            ? converter.extractIntValue(data["startZoneOffsetSeconds"], errMsg)
            : null;
    var endZoneOffset =
        data["endZoneOffsetSeconds"] != null
            ? converter.extractIntValue(data["endZoneOffsetSeconds"], errMsg)
            : null;

    var metadataMap = converter.extractJsonObject(data["metadata"], errMsg);
    var metadata = _extractMetaData(metadataMap, errMsg);

    var skinTempDeltaList = converter.extractList(data["deltas"], errMsg);
    List<SkinTemperatureDelta> skinTempDeltas = [];

    for (var delta in skinTempDeltaList) {
      var deltaMap = converter.extractJsonObject(delta, errMsg);
      var time = converter.extractDateTime(deltaMap["time"], errMsg);
      var tempDeltaData = converter.extractJsonObject(
        deltaMap["delta"],
        errMsg,
      );
      var inCelsius = converter.extractDoubleValue(
        tempDeltaData["inCelsius"],
        errMsg,
      );
      var inFahrenheit = converter.extractDoubleValue(
        tempDeltaData["inFahrenheit"],
        errMsg,
      );
      var tempDelta = TemperatureDelta(inCelsius, inFahrenheit);
      var skinTempDelta = SkinTemperatureDelta(time, tempDelta);
      skinTempDeltas.add(skinTempDelta);
    }

    var baselineData =
        data["baseline"] != null
            ? converter.extractJsonObject(data["baseline"], errMsg)
            : null;

    var baseline =
        baselineData != null
            ? Temperature(
              converter.extractDoubleValue(baselineData["inCelsius"], errMsg),
              converter.extractDoubleValue(
                baselineData["inFahrenheit"],
                errMsg,
              ),
            )
            : null;

    var measurementLocation = converter.extractIntValue(
      data["measurementLocation"],
      errMsg,
    );

    return HealthConnectSkinTemperature(
      baseline: baseline,
      deltas: skinTempDeltas,
      startTime: startTime,
      endTime: endTime,
      startZoneOffset: startZoneOffset,
      endZoneOffset: endZoneOffset,
      measurementLocation: measurementLocation,
      metadata: metadata,
    );
  }

  /// Creates a HealthConnectHeartRateVariabilityRmssd object from JSON map data.
  /// Extracts heart rate variability, time details and metadata.
  @override
  HealthConnectHeartRateVariabilityRmssd createHeartRateVariability(
    Map<String, dynamic> data,
  ) {
    var errMsg =
        "Error occured when extracting data for health connect heart rate variability";
    var time = converter.extractDateTimeFromEpochMs(data["timeEpochMs"], errMsg);
    var zoneOffset =
        data["zoneOffsetSeconds"] != null
            ? converter.extractIntValue(data["zoneOffsetSeconds"], errMsg)
            : null;
    var heartRateVariabilityMillis = converter.extractDoubleValue(
      data["heartRateVariabilityMillis"],
      errMsg,
    );

    var metadataMap = converter.extractJsonObject(data["metadata"], errMsg);
    var metadata = _extractMetaData(metadataMap, errMsg);

    return HealthConnectHeartRateVariabilityRmssd(
      time: time,
      zoneOffset: zoneOffset,
      heartRateVariabilityMillis: heartRateVariabilityMillis,
      metadata: metadata,
    );
  }

  /// Helper method to extract Health Connect metadata from a map.
  /// Creates standardized metadata objects with proper validation.
  HealthConnectMetadata _extractMetaData(
    Map<String, dynamic> data,
    String errMsg,
  ) {
    var clientRecordId =
        data["clientRecordId"] != null
            ? converter.extractStringValue(data["clientRecordId"], errMsg)
            : null;

    var clientRecordVersion =
        data["clientRecordVersion"] != null
            ? converter.extractIntValue(data["clientRecordVersion"], errMsg)
            : null;

    var dataOrigin = converter.extractStringValue(data["dataOrigin"], errMsg);
    var device =
        data["device"] != null
            ? converter.extractStringValue(data["device"], errMsg)
            : null;
    var id = converter.extractStringValue(data["id"], errMsg);
    var lastModifiedTimeString = converter.extractStringValue(
      data["lastModifiedTime"],
      errMsg,
    );
    var recordingMethod = converter.extractIntValue(
      data["recordingMethod"],
      errMsg,
    );
    var lastModifiedTime = converter.extractDateTime(
      lastModifiedTimeString,
      errMsg,
    );

    return HealthConnectMetadata(
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      dataOrigin: dataOrigin,
      device: device,
      id: id,
      recordingMethod: recordingMethod,
      lastModifiedTime: lastModifiedTime,
    );
  }
}
