import 'dart:developer';


import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

bool isValidHKHeartRateVariability(
 Map<String, dynamic> rawData,
HKDataFactory hkDataFactory
) {

  var isValid = true;
  var obj = hkDataFactory.createHeartRateVariability(rawData);
  var openMHealth = obj.toOpenMHealthHeartRateVariability();

  // Raw values
  // Required
  var rawUuid = rawData["uuid"];
  var rawStartDateStr = rawData["startDate"];
  var rawEndDateStr = rawData["endDate"];
  var rawQuantity = rawData["quantity"];
  var rawSampleType = rawData["sampleType"];
  // Optional
  var rawCount = rawData["count"];
  var rawMetadata = rawData["metadata"];
  var rawDevice = rawData["device"];
  var rawSourceRevision = rawData["sourceRevision"];

  if (rawUuid != obj.data.uuid) {
    log("found discrepancy: raw uuid $rawUuid - obj uuid ${obj.data.uuid}");
    return !isValid;
  }

  if (!obj.data.startDate.isAtSameMomentAs(DateTime.parse(rawStartDateStr))) {
    log("found discrepancy: raw start date: $rawStartDateStr - obj start date ${obj.data.startDate.toIso8601String()}");
    return !isValid;
  }

  if (!obj.data.endDate.isAtSameMomentAs(DateTime.parse(rawEndDateStr))) {
    log("found discrepancy: raw end date: $rawEndDateStr - obj end date: ${obj.data.endDate.toIso8601String()}");
    return !isValid;
  }

  var validQuantity = _validateQuantity(rawQuantity, obj);
  if (!validQuantity) {
    return !isValid;
  }

  if (rawSampleType != obj.data.sampleType.identifier) {
    log("found discrepancy: raw sample type: $rawSampleType - obj sample type ${obj.data.sampleType.identifier}");
    return !isValid;
  }

  if (rawCount != null) {
    if (rawCount != obj.data.count) {
      log("found discrepancy: raw count: $rawCount - obj count: ${obj.data.count}");
      return !isValid;
    }
  }

  if (rawMetadata != null) {
    if (rawMetadata is Map<Object?, Object?>) {
      rawMetadata.forEach((key, value) {
        if (value != obj.data.metadata![key]) {
          log("found discrepancy: raw metadata '$key' had value $value - obj had: ${obj.data.metadata![key]}");
          isValid = false;
        }
      });
    } else {
      log("found discrepancy: rawMetadata is not Map<Object?, Object?>. Found: ${rawMetadata.runtimeType}");
      return !isValid;
    }
    if (!isValid) {
      return isValid;
    }
  }

  var validDevice = _validateDevice(rawDevice, obj);
  if (!validDevice) {
    return !isValid;
  }

  if (rawSourceRevision != null) {
    if (rawSourceRevision is Map<Object?, Object?>) {
      var valid = true;
      rawSourceRevision.forEach((key, value) {
        if (value != obj.data.sourceRevision![key]) {
          log("found discrepancy: raw source revision '$key' had value '$value' - obj value ${obj.data.sourceRevision![key]}");
          valid = false;
        }
      });
      if (!valid) {
        return !isValid;
      }
    } else {
      log("found discrepancy: raw source revision is not Map<Object?, Object?>. Found: ${rawSourceRevision.runtimeType}");
      return !isValid;
    }
  }

  // Open MHealth
  var omhObj = openMHealth[0];
  if (omhObj.heartRateVariability.value != obj.data.quantity.value) {
    log("found discrepancy: obj heart rate variability: ${obj.data.quantity.value} - omh value: ${omhObj.heartRateVariability.value}" );
    return !isValid;
  }

  if (omhObj.heartRateVariability.unit != obj.data.quantity.unit) {
    log("found discrepancy: obj heart rate variability unit ${obj.data.quantity.unit} - omh unit: ${omhObj.heartRateVariability.unit}");
    return !isValid;
  }

  if (omhObj.effectiveTimeFrame.dateTime!.isAtSameMomentAs(obj.data.startDate)) {
    log("found discrepancy: obj heart rate date: ${obj.data.startDate.toString()} - omh unit: ${omhObj.effectiveTimeFrame.dateTime.toString()}");
  }

  return isValid;
}

bool _validateQuantity(dynamic rawQuantity, HkHeartRateVariability obj) {
  var isValid = true;
  if (rawQuantity is Map<Object?, Object?>) {
    if (rawQuantity["value"] != null) {
      if (rawQuantity["unit"] != null) {
        if (rawQuantity["value"] != obj.data.quantity.value) {
          log("found discrepancy: raw quantity value: ${rawQuantity["value"]} - obj quantity value: ${obj.data.quantity.value}");
          return !isValid;
        }
        if (rawQuantity["unit"] != obj.data.quantity.unit) {
          log("found discrepancy: raw quantity unit: ${rawQuantity["unit"]} - obj quantity unit: ${obj.data.quantity.unit}");
          return !isValid;
        }
      } else {
        log("found discrepancy: raw quantity did not contain key 'unit'");
        return !isValid;
      }
    } else {
      log("found discrepancy: raw quantity did not contain key 'value'");
      return !isValid;
    }
  } else {
    log("found discrepancy: raw quantity is not a Map<Object?, Object?>. Found: ${rawQuantity.runtimeType}");
    return !isValid;
  }
  return isValid;
}

bool _validateDevice(dynamic rawDevice, HkHeartRateVariability obj) {
  var isValid = true;
  if (rawDevice != null) {
    if (rawDevice is Map<Object?, Object?>) {
      var rawDeviceName = rawDevice["name"];
      var rawDeviceManufacturer = rawDevice["manufacturer"];
      var rawDeviceModel = rawDevice["model"];
      var rawDeviceHardwareVersion = rawDevice["hardwareVerison"];
      var rawDeviceSoftwareVersion = rawDevice["softwareVersion"];

      if (rawDeviceName != null) {
        if (rawDeviceName != obj.data.device!.name) {
          log("found discrepancy: raw device name $rawDeviceName - obj device name ${obj.data.device!.name}");
          return !isValid;
        }
      }

      if (rawDeviceManufacturer != null) {
        if (rawDeviceManufacturer != obj.data.device!.manufacturer) {
          log("found discrepancy: raw device manufacturer: $rawDeviceManufacturer - obj device manufacturer ${obj.data.device!.manufacturer}");
          return !isValid;
        }
      }

      if (rawDeviceModel != null) {
        if (rawDeviceModel != obj.data.device!.model) {
          log("found discrepancy: raw deviced model $rawDeviceModel - obj device model ${obj.data.device!.model}");
          return !isValid;
        }
      }

      if (rawDeviceHardwareVersion != null) {
        if (rawDeviceHardwareVersion != obj.data.device!.hardwareVersion) {
          log("found discrepancy: raw device hardware version $rawDeviceHardwareVersion - obj device hardware version ${obj.data.device!.hardwareVersion}");
          return !isValid;
        }
      }

      if (rawDeviceSoftwareVersion != null) {
        if (rawDeviceSoftwareVersion != obj.data.device!.softwareVersion) {
          log("found discrepancy: raw device software version $rawDeviceSoftwareVersion - obj device software version ${obj.data.device!.softwareVersion}");
          return !isValid;
        }
      }
    } else {
      log("found discrepancy: raw device is not Map<Object?, Object?>. Found: ${rawDevice.runtimeType}");
      return !isValid;
    }
  }
  return isValid;
}