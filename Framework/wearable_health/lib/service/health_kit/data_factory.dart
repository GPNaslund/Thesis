import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_device.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_sample_type.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

class HKDataFactoryImpl implements HKDataFactory {
  JsonConverter jsonConverter;

  HKDataFactoryImpl(this.jsonConverter);

  @override
  HKBodyTemperature createBodyTemperature(Map<String, dynamic> data) {
    var errMsg = "Error occured when extracting hk body temperature data";
    var quantitySample = _createQuantitySample(data, errMsg);
    return HKBodyTemperature(quantitySample);
  }

  @override
  HKHeartRate createHeartRate(Map<String, dynamic> data) {
    var errMsg = "Error occured when extracting hk heart rate data";
    var quantitySample = _createQuantitySample(data, errMsg);
    return HKHeartRate(quantitySample);
  }

  HKQuantitySample _createQuantitySample(
    Map<String, dynamic> data,
    String errMsg,
  ) {
    var quantity = _createQuantity(data, errMsg);
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
    var device = data["device"] ? _createDevice(data, errMsg) : null;

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

  HKQuantity _createQuantity(Map<String, dynamic> data, String errMsg) {
    var value = jsonConverter.extractDoubleValue(data["value"], errMsg);
    var unit = jsonConverter.extractStringValue(data["unit"], errMsg);
    return HKQuantity(doubleValue: value, unit: unit);
  }

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
