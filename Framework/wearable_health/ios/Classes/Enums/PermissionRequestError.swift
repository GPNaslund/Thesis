import Foundation

enum PermissionsRequestError: Error, LocalizedError {
    case invalidArgumentType(String?)
    case missingDataTypesKey
    case invalidDataTypesType(String?)
    case invalidDataTypeStringInList(Any)
    case emptyInputList
    case noValidHealthKitTypesFound
    case unknownDataTypeString(String)

    var errorDescription: String? {
        switch self {
        case .invalidArgumentType(let expected):
            return "Invalid argument type. Expected [String: Any]\(expected ?? "")."
        case .missingDataTypesKey:
            return "Argument is missing the key 'dataTypes'."
        case .invalidDataTypesType(let expected):
            return "dataTypes has wrong type. Expected [String]\(expected ?? "")."
        case .invalidDataTypeStringInList(let value):
            return "The dataTypes list contained a non String value: \(value)."
        case .emptyInputList:
             return "dataTypes list cannot be empty."
        case .noValidHealthKitTypesFound:
            return "dataTypes list contained strings but couldnt map to any known HealthKit datatype"
        case .unknownDataTypeString(let typeString):
            return "An unknown dataType string was found: \(typeString)."
        }
    }
}
