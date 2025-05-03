import Foundation
import HealthKit

struct GetDataRequest {
    let startDate: Date
    let endDate: Date
    let objectTypesToQuery: Set<HKObjectType>
    
    
    init(arguments: Any?) throws {
        guard let argsDict = arguments as? [String: Any] else {
            throw GetDataRequestError.invalidArgumentType
        }

        guard let startString = argsDict["start"] as? String else {
            if argsDict["start"] == nil { throw GetDataRequestError.missingKey("start") }
            throw GetDataRequestError.invalidValueType(key: "start", expected: "String", actual: String(describing: type(of: argsDict["start"]!)))
        }
        guard let endString = argsDict["end"] as? String else {
             if argsDict["end"] == nil { throw GetDataRequestError.missingKey("end") }
            throw GetDataRequestError.invalidValueType(key: "end", expected: "String", actual: String(describing: type(of: argsDict["end"]!)))
        }
        guard let dataTypesAny = argsDict["dataTypes"] else {
            throw GetDataRequestError.missingKey("dataTypes")
        }
        guard let dataTypeStrings = dataTypesAny as? [String] else {
            if let anyArray = dataTypesAny as? [Any] {
                for item in anyArray {
                    if !(item is String) {
                        throw GetDataRequestError.invalidDataTypeStringInList(item)
                    }
                }
            }
            throw GetDataRequestError.invalidValueType(key: "dataTypes", expected: "[String]", actual: String(describing: type(of: dataTypesAny)))
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var parsedStartDate: Date?
        if let date = isoFormatter.date(from: startString) {
             parsedStartDate = date
        } else {
            isoFormatter.formatOptions = .withInternetDateTime
            parsedStartDate = isoFormatter.date(from: startString)
        }
        guard let startDate = parsedStartDate else {
             throw GetDataRequestError.invalidDateString(key: "start", value: startString)
        }
        
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsedEndDate: Date?
        if let date = isoFormatter.date(from: endString) {
            parsedEndDate = date
        } else {
             isoFormatter.formatOptions = .withInternetDateTime
             parsedEndDate = isoFormatter.date(from: endString)
        }
        guard let endDate = parsedEndDate else {
              throw GetDataRequestError.invalidDateString(key: "end", value: endString)
        }

        guard startDate <= endDate else {
            throw GetDataRequestError.startAfterEndDate(start: startDate, end: endDate)
        }

        var resolvedObjectTypes: Set<HKObjectType> = []
        for typeString in dataTypeStrings {
            if let objectType = HealthDataType.getObjectType(from: typeString) {
                resolvedObjectTypes.insert(objectType)
            } else {
                print("Info [GetDataRequest]: Ignoring unknown data type string: \(typeString)")
            }
        }

        if resolvedObjectTypes.isEmpty && !dataTypeStrings.isEmpty {
             throw GetDataRequestError.noValidObjectTypes
        }

        self.startDate = startDate
        self.endDate = endDate
        self.objectTypesToQuery = resolvedObjectTypes
    }
}
