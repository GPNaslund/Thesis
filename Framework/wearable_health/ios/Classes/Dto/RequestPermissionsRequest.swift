import Foundation
import HealthKit

struct RequestPermissionsRequest {
    let objectTypesToRequest: Set<HKObjectType>


    init(arguments: Any?) throws {
        guard let argsDict = arguments as? [String: Any] else {
            throw PermissionsRequestError.invalidArgumentType(String(describing: [String: Any].self))
        }

        guard let dataTypesValue = argsDict["dataTypes"] else {
            throw PermissionsRequestError.missingDataTypesKey
        }

        guard let dataTypeStrings = dataTypesValue as? [String] else {
            if let anyArray = dataTypesValue as? [Any] {
                for item in anyArray {
                    if !(item is String) {
                        throw PermissionsRequestError.invalidDataTypeStringInList(item)
                    }
                }
            }
            throw PermissionsRequestError.invalidDataTypesType(String(describing: [String].self))
        }

   
        if dataTypeStrings.isEmpty {
            throw PermissionsRequestError.emptyInputList
        }

        
        var resolvedObjectTypes: Set<HKObjectType> = []
        for typeString in dataTypeStrings {
            if let objectType = HealthDataType.getObjectType(from: typeString) {
                resolvedObjectTypes.insert(objectType)
            } else {
                print("Info: Ignoring unknown data type string: \(typeString)")
                throw PermissionsRequestError.unknownDataTypeString(typeString)
            }
        }

        
        if resolvedObjectTypes.isEmpty && !dataTypeStrings.isEmpty {
            throw PermissionsRequestError.noValidHealthKitTypesFound
        }

        self.objectTypesToRequest = resolvedObjectTypes
    }
}
