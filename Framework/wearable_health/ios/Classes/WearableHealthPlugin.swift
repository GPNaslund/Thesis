import Flutter
import HealthKit
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    let healthStore = HKHealthStore()
    var dataTypes = Set<HKObjectType>()

    let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {        
            print("Got call: \(call.method)")
            let callType: CallType = CallType.fromString(val: call.method)

            switch callType {
            case .getPlatformVersion:
                result("iOS " + UIDevice.current.systemVersion)
            case .hasPermissions:
                try checkHasPermissions(call: call, result: result)
            case .requestPermissions:
                try requestPermissions(call: call, result: result)
            case .dataStoreAvailability:
                checkDataStoreAvailability(result: result)
            case .getData:
                try getData(call: call, result: result)
            case .unkown:
                fatalError("Not implemented")
            }
        } catch InvalidArgument.wrongType(let message) {
            print(message)
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT_ERROR",
                    message: message,
                    details: nil
                )
            )
            return
        } catch InvalidState.permissionValidationMissing(let message) {
            print(message)
            result(
                FlutterError(
                    code: "INVALID_STATE_ERROR",
                    message: message,
                    details: nil
                )
            )
            return
        } catch {
            print("An unexpected error occured: \(error.localizedDescription)")
            result(
                FlutterError(
                    code: "UNEXPECTED_ERROR",
                    message: error.localizedDescription,
                    details: nil
                )
            )
        }
    }

    private func getData(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        guard let args = call.arguments as? [String: Any],
            let startString = args["start"] as? String,
            let endString = args["end"] as? String else {
                throw InvalidArgument.wrongType(message: "[getData] Missing 'start' and/or 'end' as arguments to method")
            }

        guard let startDate = dateFormatter.date(from: startString),
            let endDate = dateFormatter.date(from: endString) else {
                throw InvalidArgument.wrongType(message: "[getData] Could not parse date strings")
            }

        if dataTypes.isEmpty {
            throw InvalidState.permissionValidationMissing(message: "[getData] No datatypes are set which means checkPermissions and/or requestPermissions has not been called")
        }

        var collectedData: [[String: String]] = []
        let group = DispatchGroup()

        for objectType in dataTypes {
            guard let sampleType = objectType as? HKSampleType else {
                print("[getData] Skipping non-sample type: \(objectType.identifier)")
                continue
            }

            print("[getData] Querying for type: \(sampleType.identifier) between \(startDate) and \(endDate)")
            group.enter()

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in 
                defer { group.leave() }

                if let error = error {
                    print("[getData] Error fetching \(sampleType.identifier): \(error.localizedDescription)")
                    return
                }

                guard let validSamples = samples, !validSamples.isEmpty else {
                    print("[getData] No samples found for \(sampleType.identifier) in the given range")
                    return
                }

                print("[getData] Found \(validSamples.count) samples for \(sampleType.identifier)")

                DispatchQueue.main.async {
                    for sample in validSamples {
                        var dataPoint: [String: String] = [:]
                        dataPoint["uuid"] = sample.uuid.uuidString
                        dataPoint["startDate"] = self.dateFormatter.string(from: sample.startDate)
                        dataPoint["endDate"] = self.dateFormatter.string(from: sample.endDate)
                        dataPoint["sourceBundleId"] = sample.sourceRevision.source.bundleIdentifier
                        dataPoint["sourceName"] = sample.sourceRevision.source.name

                        if let quantitySample = sample as? HKQuantitySample {
                            let quantityTypeIdentifier = quantitySample.quantityType.identifier
                            var unit: HKUnit? = nil
                            var typeString: String? = nil

                            switch quantityTypeIdentifier {
                                case HKQuantityTypeIdentifier.heartRate.rawValue:
                                    unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                                    typeString = "heartRate"
                                case HKQuantityTypeIdentifier.bodyTemperature.rawValue:
                                    unit = HKUnit.degreeCelsius()
                                    typeString = "bodyTemperature"
                                default:
                                    print("[getData] Skipping unsupported quantity type: \(quantityTypeIdentifier)")
                                    continue
                            }

                            if let validUnit = unit, let validTypestring = typeString {
                                dataPoint["value"] = String(quantitySample.quantity.doubleValue(for: validUnit))
                                dataPoint["unit"] = validUnit.unitString
                                dataPoint["dataType"] = validTypestring
                            }
                        }

                        else {
                            print("[getData] Skipping sample type that is not supported \(type(of: sample))")
                            continue
                        }

                        if dataPoint["value"] != nil && dataPoint["dataType"] != nil {
                            collectedData.append(dataPoint)
                        } else {
                            print("[getData] Error: Failed to extract value/dataType for sample: \(sample.uuid)")
                        }
                    }
                }
            }

            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            print("[getData] All queries finished. Returning \(collectedData.count) data points")
            result(collectedData)
        }
    }

    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        try assignHKDataTypes(call: call)
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: dataTypes) {
                (success: Bool, error: Error?) in
                if success {
                    print("HealthKit authorization request succeeded")
                    result(true)
                } else {
                    print(
                        "HealthKit authorization failed: \(error?.localizedDescription ?? "by User action")"
                    )
                    result(false)
                }
            }
        }
    }

    private func checkHasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) throws {
        try assignHKDataTypes(call: call)

        var allIsPermitted = true
        dataTypes.forEach { type in
            if allIsPermitted {
                let authStatus = healthStore.authorizationStatus(for: type)
                if authStatus != .sharingAuthorized {
                    allIsPermitted = false
                }
            }
        }

        result(allIsPermitted)
    }

    private func assignHKDataTypes(call: FlutterMethodCall) throws {
        if (dataTypes.count != 0) {
            print("[assignHKDataTypes] dataTypes is allready assigned")
            return
        }

        
        print(
            "[assignHKDataTypes] Trying to extract data types from: \(call.arguments ?? "Call argument null")"
        )

        guard let argumentsDict = call.arguments as? [String: Any],
            let permissionsValue = argumentsDict["dataTypes"],
            let healthValueStrings = permissionsValue as? [String]
        else {
            if !(call.arguments is [String: Any]) {
                throw InvalidArgument.wrongType(message: "[assignHKDataTypes] Error: call.arguments was not a dictionary [String: Any]. Actual type: \(type(of: call.arguments))")
            } else if (call.arguments as! [String: Any])["dataTypes"] == nil {
                throw InvalidArgument.wrongType(message: "[assignHKDataTypes] Error: Dictionary did not contain the key 'dataTypes'.")
            } else if !((call.arguments as! [String: Any])["dataTypes"] is [String]) {
                throw InvalidArgument.wrongType(message: "[assignHKDataTypes] Error: Value for key 'permissions' was not an array of Strings [String]. Actual type: \(type(of: (call.arguments as! [String: Any])["permissions"]))")
            } else {
                throw InvalidArgument.wrongType(message: "[assignHKDataTypes] Error: Failed to extract 'permissions' array of strings for an unknown reason.")
            }
        }

        if healthValueStrings.count == 0 {
            throw InvalidArgument.wrongType(message: "[assignHKDataTypes] No dataType strings provided")
        }

        print("[assignHKDataTypes] Recieved health values: \(healthValueStrings)")

        for valueString in healthValueStrings {
            switch valueString {
                case "heartRate": 
                    if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
                        dataTypes.insert(heartRateType)
                        print("[assignHKDataTypes] Added heartRate type")
                    } else {
                        print("[assignHKDataTypes] Error: Could not get HKQuantityType for heartRate")
                    }
                case "bodyTemperature":
                    if let bodyTempType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) {
                        dataTypes.insert(bodyTempType)
                        print("[assignHKDataTypes] Added bodyTempType")
                    } else {
                        print("[assignHKDataTypes] Error: Could not get HKQuantityType for bodyTemperature")
                    }
                default:
                    throw InvalidArgument.wrongType(message: "[assignHKDataTypes] Error: Undefined data type \(valueString)")
            }
        }
    }

    private func checkDataStoreAvailability(result: @escaping FlutterResult) {
        if HKHealthStore.isHealthDataAvailable() {
            guard let healthAppUrl = URL(string: "x-apple-health://") else {
                print("Error creating Health App URL")
                result(
                    FlutterError(
                        code: "URL_CREATION_FAILED", message: "Failed to create URL resource",
                        details: "Failed to create URL for checking health app URL"))
                return
            }
            if UIApplication.shared.canOpenURL(healthAppUrl) {
                result(DataStoreAvailability.available)
            } else {
                result(DataStoreAvailability.unavailable)
            }
        } else {
            result(DataStoreAvailability.unavailable)
        }
    }

}
