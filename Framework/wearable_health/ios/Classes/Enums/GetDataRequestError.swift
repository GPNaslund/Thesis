import Foundation

enum GetDataRequestError: Error, LocalizedError {
    case invalidArgumentType
    case missingKey(String)
    case invalidValueType(key: String, expected: String, actual: String)
    case invalidDateString(key: String, value: String, error: Error? = nil)
    case invalidDataTypeStringInList(Any)
    case noValidObjectTypes
    case startAfterEndDate(start: Date, end: Date)

    var errorDescription: String? {
        switch self {
        case .invalidArgumentType:
            return "Invalid argument type. Expected [String: Any]."
        case .missingKey(let key):
            return "Argument is missing the necessary key: '\(key)'."
        case .invalidValueType(let key, let expected, let actual):
            return "Invalid value type of '\(key)'. Expected \(expected), but got \(actual)."
        case .invalidDateString(let key, let value, let error):
            var baseMessage = "Could not parse date value for '\(key)': '\(value)'. Expected ISO8601-format."
            if let error = error {
                baseMessage += " Internal error: \(error.localizedDescription)"
            }
            return baseMessage
        case .invalidDataTypeStringInList(let value):
            return "dataTypes list contained non string value: \(value)."
        case .noValidObjectTypes:
             return "dataTypes contained strings but none could be mapped to a known HealthKit-type."
        case .startAfterEndDate(let start, let end):
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .medium
            return "Start date (\(formatter.string(from: start))) cant be after end date (\(formatter.string(from: end)))."
        }
    }
}
