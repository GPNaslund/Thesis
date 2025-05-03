import HealthKit
import Foundation

enum HealthDataType: String, CaseIterable {
    case heartRate = "heartRate"
    case bodyTemperature = "bodyTemperature"

    func getObjectType() -> HKObjectType? {
        switch self {
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)
        case .bodyTemperature:
            return HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        }
    }

    static func getObjectType(from stringValue: String) -> HKObjectType? {
        guard let dataType = HealthDataType(rawValue: stringValue) else {
            print("Warning [HealthDataType]: Unsupported HealthDataType string received: \(stringValue)")
            return nil
        }
        return dataType.getObjectType()
    }

    static func from(objectType: HKObjectType) -> HealthDataType? {
        for dataTypeCase in HealthDataType.allCases {
            guard let caseObjectType = dataTypeCase.getObjectType() else {
                continue
            }
            if caseObjectType == objectType {
                return dataTypeCase
            }
        }
        
         if objectType.identifier == HKQuantityTypeIdentifier.heartRate.rawValue || objectType.identifier == HKQuantityTypeIdentifier.bodyTemperature.rawValue {
            print("Warning [HealthDataType]: Could not map supported HKObjectType '\(objectType.identifier)' back to HealthDataType enum.")
         }
        return nil
    }
}
