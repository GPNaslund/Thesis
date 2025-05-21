import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_device.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_sample_type.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

/// Implementation of HKDataFactory that creates HealthKit (iOS)
/// data objects from JSON map structures.
class HKDataFactoryImpl implements HKDataFactory {
  /// JSON converter for safe type extraction.
  JsonConverter jsonConverter;

  /// Creates a new factory with the specified JSON converter.
  HKDataFactoryImpl(this.jsonConverter);

  /// Creates an HKBodyTemperature object from JSON map data.
  /// Extracts and validates required fields for body temperature measurements.
  @override
  HKBodyTemperature createBodyTemperature(Map<String, dynamic> data) {
    var errMsg = "Error occured when extracting hk body temperature data";
    var quantitySample = _createQuantitySample(data, errMsg);
    return HKBodyTemperature(quantitySample);
  }

  /// Creates an HKHeartRate object from JSON map data.
  /// Extracts and validates required fields for heart rate measurements.
  @override
  HKHeartRate createHeartRate(Map<String, dynamic> data) {
    var errMsg = "Error occured when extracting hk heart rate data";
    var quantitySample = _createQuantitySample(data, errMsg);
    return HKHeartRate(quantitySample);
  }

  /// Creates an HKHeartRateVariability object from JSON map data.
  /// Extracts and validates required fields for heart rate variability measurements.
  @override
  HkHeartRateVariability createHeartRateVariability(Map<String, dynamic> data) {
    var errMsg = "Error occured when extracting hk heart rate variability data";
    var quantitySample = _createQuantitySample(data, errMsg);
    return HkHeartRateVariability(quantitySample);
  }

  /// Helper method to create an HKQuantitySample from JSON map data.
  /// Handles common properties for all quantity-based health samples.
  HKQuantitySample _createQuantitySample(
    Map<String, dynamic> data,
    String errMsg,
  ) {

  Map<String, dynamic> formattedQuantity = Map<String, dynamic>.from(data["quantity"]);
    var quantity = _createQuantity(formattedQuantity, errMsg);
    var count =
        data["count"] != null
            ? jsonConverter.extractIntValue(data["count"], errMsg)
            : null;
    var uuid = jsonConverter.extractStringValue(data["uuid"], errMsg);
    var startDate = jsonConverter.extractDateTime(data["startDate"], errMsg);
    var endDate = jsonConverter.extractDateTime(data["endDate"], errMsg);
    var sampleTypeData = jsonConverter.extractStringValue(
      data["sampleType"],
      errMsg,
    );
    var sampleType = HKSampleType(identifier: sampleTypeData);
    var metadata =
        data["metadata"] != null
            ? jsonConverter.extractJsonObject(data["metadata"], errMsg)
            : null;
    var device = data["device"] != null ? _createDevice(data, errMsg) : null;

    var sourceRevision =
        data["sourceRevision"] != null
            ? jsonConverter.extractJsonObject(data["sourceRevision"], errMsg)
            : null;

    return HKQuantitySample(
      uuid: uuid,
      startDate: startDate,
      endDate: endDate,
      metadata: metadata,
      device: device,
      sourceRevision: sourceRevision,
      quantity: quantity,
      sampleType: sampleType,
      count: count,
    );
  }

  /// Helper method to create an HKQuantity from JSON map data.
  /// Extracts value and unit information.
  HKQuantity _createQuantity(Map<String, dynamic> data, String errMsg) {
    var value = jsonConverter.extractDoubleValue(data["value"], errMsg);
    var unit = jsonConverter.extractStringValue(data["unit"], errMsg);
    return HKQuantity(value: value, unit: unit);
  }

  /// Helper method to create an HKDevice from JSON map data.
  /// Extracts device information such as name, manufacturer, and versions.
  HKDevice _createDevice(Map<String, dynamic> data, String errMsg) {
    var deviceMap = jsonConverter.extractMap(data, errMsg);
    var name =
        deviceMap["name"] != null
            ? jsonConverter.extractStringValue(deviceMap["name"], errMsg)
            : null;
    var manufacturer =
        deviceMap["manufacturer"] != null
            ? jsonConverter.extractStringValue(
              deviceMap["manufacturer"],
              errMsg,
            )
            : null;
    var model =
        deviceMap["model"] != null
            ? jsonConverter.extractStringValue(deviceMap["model"], errMsg)
            : null;
    var hardwareVersion =
        deviceMap["hardwareVersion"] != null
            ? jsonConverter.extractStringValue(
              deviceMap["hardwareVersion"],
              errMsg,
            )
            : null;
    var softwareVersion =
        deviceMap["softwareVersion"] != null
            ? jsonConverter.extractStringValue(
              deviceMap["softwareVersion"],
              errMsg,
            )
            : null;
    return HKDevice(
      name: name,
      manufacturer: manufacturer,
      model: model,
      hardwareVersion: hardwareVersion,
      softwareVersion: softwareVersion,
    );
  }
}
