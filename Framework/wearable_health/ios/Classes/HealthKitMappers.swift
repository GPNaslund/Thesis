import Foundation
import HealthKit

func mapHKSampleToDictionary(_ sample: HKSample) -> [String: Any?]? {
    guard let quantitySample = sample as? HKQuantitySample else {
        print("Warning [mapHKSampleToDictionary]: Skipping non-quantity sample type: \(type(of: sample)). UUID: \(sample.uuid)")
        return nil
    }

    guard let healthDataType = HealthDataType.from(objectType: quantitySample.quantityType) else {
         print("Warning [mapHKSampleToDictionary]: Skipping sample with unsupported HKQuantityType: \(quantitySample.quantityType.identifier). UUID: \(sample.uuid)")
        return nil
    }

    guard let standardUnit = quantitySample.quantityType.getStandardUnit() else {
         print("Warning [mapHKSampleToDictionary]: Could not get standard unit for \(quantitySample.quantityType.identifier). Skipping sample. UUID: \(sample.uuid)")
        return nil
    }

    var map: [String: Any?] = [:]
    map["uuid"] = sample.uuid.uuidString
    map["startTime"] = sample.startDate.toISO8601String()
    map["endTime"] = sample.endDate.toISO8601String()
    map["sourceId"] = sample.sourceRevision.source.bundleIdentifier
    map["sourceName"] = sample.sourceRevision.source.name

    if let metadata = sample.metadata, !metadata.isEmpty {
        var serializableMetadata: [String: Any] = [:]
        for (key, value) in metadata {
            if value is String || value is NSNumber || value is Bool {
                serializableMetadata[key] = value
            } else if let dateValue = value as? Date {
                serializableMetadata[key] = dateValue.toISO8601String()
            } else {
                print("Warning [mapHKSampleToDictionary]: Skipping metadata key '\(key)' with non-serializable type \(type(of: value)).")
            }
        }
        map["metadata"] = serializableMetadata.isEmpty ? nil : serializableMetadata
    } else {
        map["metadata"] = nil
    }

    map["dataType"] = healthDataType.rawValue
    map["value"] = quantitySample.quantity.doubleValue(for: standardUnit)
    map["unit"] = standardUnit.unitString

    return map
}

