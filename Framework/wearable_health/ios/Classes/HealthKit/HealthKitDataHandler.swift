import Flutter
import HealthKit

public class HealthKitDataHandler {
    let healthStore: HKHealthStore

    init(_ store: HKHealthStore) {
        healthStore = store
    }

    public func getData(
        call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        let dataCollectionQueue = DispatchQueue(
            label: "com.wearablehealth.datacollection.serial")
        var allMappedSamplesFromQueries: [[String: Any?]] = []

        guard let arguments = call.arguments as? [String: Any] else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Arguments must be a dictionary.", details: nil))
            return
        }

        var objectTypesToQuery = [HKObjectType]()
        var startDate: Date?
        var endDate: Date?

        if let startString = arguments["start"] as? String {
            if let date = dateFromISO8601String(startString) {
                startDate = date
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message:
                            "Failed to parse 'start' date string: \(startString). Expected ISO8601 format.",
                        details: nil))
                return
            }
        } else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Missing 'start' date in arguments.", details: nil)
            )
            return
        }

        if let endString = arguments["end"] as? String {
            if let date = dateFromISO8601String(endString) {
                endDate = date
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message:
                            "Failed to parse 'end' date string: \(endString). Expected ISO8601 format.",
                        details: nil))
                return
            }
        } else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Missing 'end' date in arguments.", details: nil))
            return
        }

        guard let validStartDate = startDate, let validEndDate = endDate else {
            result(
                FlutterError(
                    code: "INTERNAL_ERROR",
                    message: "Start or end date became nil after parsing.",
                    details: nil))
            return
        }

        if let typeStrings = arguments["types"] as? [String] {
            if typeStrings.isEmpty {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENT",
                        message: "'types' array cannot be empty.", details: nil)
                )
                return
            }
            for typeString in typeStrings {
                if let hkObjectType = rawValueConverter(rawValue: typeString) {
                    objectTypesToQuery.append(hkObjectType)
                } else {
                    print(
                        "[HealthKitDataHandler] Could not convert the string \(typeString) to HKObjectType. It will be ignored."
                    )
                }
            }
        } else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "'types' argument must be a list of strings.",
                    details: nil))
            return
        }

        guard !objectTypesToQuery.isEmpty else {
            print(
                "[HealthKitDataHandler]: No valid HealthKit types specified in the request after filtering."
            )
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT",
                    message:
                        "No valid HealthKit types provided or all were unrecognized.",
                    details: nil))
            return
        }

        print(
            "[HealthKitDataHandler]: Preparing to query for types: \(objectTypesToQuery.map { $0.identifier }) between \(validStartDate) and \(validEndDate)"
        )

        let group = DispatchGroup()

        for objectType in objectTypesToQuery {
            guard let sampleType = objectType as? HKSampleType else {
                print(
                    "[HealthKitDataHandler]: Skipping non-sample type: \(objectType.identifier)"
                )
                continue
            }

            group.enter()
            let predicate = HKQuery.predicateForSamples(
                withStart: validStartDate, end: validEndDate,
                options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in

                if let error = error {
                    print(
                        "[HealthKitDataHandler]: Error fetching \(sampleType.identifier): \(error.localizedDescription)"
                    )
                    group.leave()
                    return
                }
                guard let validSamples = samples, !validSamples.isEmpty else {
                    print(
                        "[HealthKitDataHandler]: No samples found for \(sampleType.identifier)."
                    )
                    group.leave()
                    return
                }

                print(
                    "[HealthKitDataHandler]: Found \(validSamples.count) samples for \(sampleType.identifier). Mapping..."
                )

                let mappedSamples = validSamples.compactMap {
                    mapHKSampleToDictionary($0)
                }

                if !mappedSamples.isEmpty {
                    dataCollectionQueue.async {
                        allMappedSamplesFromQueries.append(
                            contentsOf: mappedSamples)
                        group.leave()
                    }
                } else {
                    print(
                        "[HealthKitDataHandler]: No mappable samples resulted for \(sampleType.identifier)."
                    )
                    group.leave()
                }
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            print(
                "[HealthKitDataHandler]: All queries finished. Total mapped samples collected: \(allMappedSamplesFromQueries.count)"
            )
            dataCollectionQueue.sync {
                var groupedResult: [String: [[String: Any?]]] = [:]
                for sampleMap in allMappedSamplesFromQueries {
                    if let typeIdentifier = sampleMap["dataType"] as? String {
                        if groupedResult[typeIdentifier] == nil {
                            groupedResult[typeIdentifier] = []
                        }
                        groupedResult[typeIdentifier]?.append(sampleMap)
                    } else {
                        print(
                            "[HealthKitDataHandler]: Warning - sample map missing 'dataType'"
                        )
                    }
                }
                
                if groupedResult.isEmpty && !objectTypesToQuery.isEmpty
                    && allMappedSamplesFromQueries.isEmpty
                {
                    print(
                        "[HealthKitDataHandler]: No data found for the requested types and time range."
                    )
                }
                print(
                    "[HealthKitDataHandler]: Data grouped. Sending to Flutter.")
                
                result(groupedResult)
            }
        }
    }

    private func dateFromISO8601String(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        if let date = formatter.date(from: dateString) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }

}
