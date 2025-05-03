import Foundation
import HealthKit

struct CheckPermissionsResponse {
    let grantedObjectTypes: Set<HKObjectType>

    init(granted: Set<HKObjectType>) {
        self.grantedObjectTypes = granted
    }

    func toMap() -> [String: [String]] {
        var permissionStrings: [String] = []

        for objectType in grantedObjectTypes {
            if let healthDataType = HealthDataType.from(objectType: objectType) {
                permissionStrings.append(healthDataType.rawValue)
            } else {
                print("[CheckPermissionsResponse] Warning: Permitted HKObjectType '\(objectType.identifier)' could not map back to its HealthDataType raw value.")
            }
        }

        return ["permissions": permissionStrings]
    }
}
