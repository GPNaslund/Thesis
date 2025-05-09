import Foundation
import HealthKit

public func groupHealthKitSamplesByType(_ samples: [HKSample]) -> [String: [[String: Any?]]] {
    var groupedSamples: [String: [[String: Any?]]] = [:]
    
    for sample in samples {
        let typeIdentifierKey = sample.sampleType.identifier
        
        if let mappedSample = mapHKSampleToDictionary(sample) {
            if groupedSamples[typeIdentifierKey] == nil {
                groupedSamples[typeIdentifierKey] = []
            }
            groupedSamples[typeIdentifierKey]?.append(mappedSample)
        }
    }
    return groupedSamples
}

func mapHKSampleToDictionary(_ sample: HKSample) -> [String: Any?]? {
    var map: [String: Any?] = [:]
    
    // HKSample properties
    map["uuid"] = sample.uuid.uuidString
    map["startTime"] = sample.startDate.toISO8601String()
    map["endTime"] = sample.endDate.toISO8601String()
    map["dataType"] = sample.sampleType.identifier
    
    // Source information
    let sourceRevision = sample.sourceRevision
    map["sourceBundleId"] = sourceRevision.source.bundleIdentifier
    map["sourceName"] = sourceRevision.source.name
    map["sourceVersion"] = sourceRevision.version
    map["sourceProductType"] = sourceRevision.productType
    if #available(iOS 9.0, *) {
        let osVersion = sourceRevision.operatingSystemVersion
        map["sourceOperatingSystemVersion"] = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    } else {
        map["sourceOperatingSystemVersion"] = nil
    }
    
    // Device information
    if let device = sample.device {
        map["deviceName"] = device.name
        map["deviceManufacturer"] = device.manufacturer
        map["deviceModel"] = device.model
        map["deviceHardwareVersion"] = device.hardwareVersion
        map["deviceFirmwareVersion"] = device.firmwareVersion
        map["deviceSoftwareVersion"] = device.softwareVersion
        map["deviceLocalIdentifier"] = device.localIdentifier
        map["deviceUDIDeviceIdentifier"] = device.udiDeviceIdentifier
    } else {
        map["deviceName"] = nil
        map["deviceManufacturer"] = nil
        map["deviceModel"] = nil
        map["deviceHardwareVersion"] = nil
        map["deviceFirmwareVersion"] = nil
        map["deviceSoftwareVersion"] = nil
        map["deviceLocalIdentifier"] = nil
        map["deviceUDIDeviceIdentifier"] = nil
    }

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
    
    // Type specific data
    if let quantitySample = sample as? HKQuantitySample {
        addQuantitySampleData(quantitySample, to: &map)
    } else {
        print("[HealthKitMappers] Sample is of unkown type")
    }
    return map
}


private func addQuantitySampleData(_ quantitySample: HKQuantitySample, to map: inout [String: Any?]) {
    if let standardUnit = quantitySample.quantityType.getStandardUnit() {
        map["value"] = quantitySample.quantity.doubleValue(for: standardUnit)
        map["unit"] = standardUnit.unitString
    } else {
        print("[addQuantitySampleData]: No standard unit from getStandardUnit() for \(quantitySample.quantityType.identifier). 'value' and 'unit' fields might be nil. UUID: \(quantitySample.uuid)")
        map["value"] = nil
        map["unit"] = nil
    }

    if quantitySample.quantityType.aggregationStyle == .discrete {
        let countSpecificUnit = HKUnit.count()

        if quantitySample.quantity.is(compatibleWith: countSpecificUnit) {
            let doubleCountValue = quantitySample.quantity.doubleValue(for: countSpecificUnit)

            if floor(doubleCountValue) == doubleCountValue &&
               doubleCountValue >= Double(Int.min) &&
               doubleCountValue <= Double(Int.max) {
                map["count"] = Int(doubleCountValue)
            } else {
                print("[addQuantitySampleData]: Discrete quantity \(quantitySample.quantityType.identifier) value (\(doubleCountValue)) is not a whole number or is out of Int range. 'count' will be nil. UUID: \(quantitySample.uuid)")
                map["count"] = nil
            }
        } else {
            print("[addQuantitySampleData]: Discrete quantity \(quantitySample.quantityType.identifier) is not compatible with HKUnit.count(). Skipping 'count' field. UUID: \(quantitySample.uuid)")
            map["count"] = nil
        }
    } else {
        map["count"] = nil
    }
}
