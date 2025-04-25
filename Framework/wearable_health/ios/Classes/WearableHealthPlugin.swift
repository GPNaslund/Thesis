import Flutter
import HealthKit
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    let healthStore = HKHealthStore()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Got call: \(call.method)")
        let callType: CallType = CallType.fromString(val: call.method)

        switch callType {
        case .getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
        case .hasPermissions:
            checkHasPermissions(call: call, result: result)
        case .requestPermissions:
            requestPermissions(call: call, result: result)
        case .dataStoreAvailability:
            checkDataStoreAvailability(result: result)
        case .unkown:
            fatalError("Not implemented")
        }
    }

    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let typesToProcess = extractHKDataTypesFromCall(call: call)

        if typesToProcess == nil {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT_TYPE",
                    message: "Invalid argument type. Must be a list of String", details: nil))
            return
        }

        if typesToProcess!.isEmpty {
            result(
                FlutterError(
                    code: "NO_TYPES_TO_CHECK",
                    message: "No valid types were provided to request permission for", details: nil)
            )
            return
        }

        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToProcess) {
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

    private func checkHasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let typesToProcess = extractHKDataTypesFromCall(call: call)

        if typesToProcess == nil {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENT_TYPE",
                    message: "Invalid argument type. Must be List of String", details: nil))
            return
        }

        if typesToProcess!.isEmpty {
            result(
                FlutterError(
                    code: "NO_TYPES_TO_CHECK", message: "No valid types were provided to check",
                    details: nil))
            return
        }

        var allIsPermitted = true
        typesToProcess!.forEach { type in
            if allIsPermitted {
                let authStatus = healthStore.authorizationStatus(for: type)
                if authStatus != .sharingAuthorized {
                    allIsPermitted = false
                }
            }
        }

        result(allIsPermitted)
    }

    private func extractHKDataTypesFromCall(call: FlutterMethodCall) -> Set<HKObjectType>? {
        print("Trying to extract data types from: \(call.arguments)")

        guard let healthValueStrings = call.arguments.permissions as? [String] else {
            return nil
        }

        print("Recieved health values: \(healthValueStrings)")
        var typesToProcess = Set<HKObjectType>()

        for valueString in healthValueStrings {
            print("Handling: \(valueString)")
            let type = hkObjectConverter(rawValue: valueString)
            if type != nil {
                print("Type found: \(type!)")
                typesToProcess.insert(type!)
            } else {
                print("Unknown type: \(valueString)")
            }
        }

        return typesToProcess
    }

    private func hkObjectConverter(rawValue: String) -> HKObjectType? {
        print("Processing raw value: \(rawValue)")

        let quantityType = hkQuantityTypeConverter(rawValue: rawValue)
        if quantityType != nil {
            return quantityType
        }

        let categoryType = hkCategoryTypeConverter(rawValue: rawValue)
        if categoryType != nil {
            return categoryType
        }

        print("Unknown type: \(rawValue)")
        return nil
    }

    private func hkQuantityTypeConverter(rawValue: String) -> HKQuantityType? {
        let quantityIdentifier = HKQuantityTypeIdentifier(rawValue: rawValue)
        if let quantityType = HKQuantityType.quantityType(forIdentifier: quantityIdentifier) {
            print("Quantity type identified: \(rawValue)")
            return quantityType
        }
        return nil
    }

    private func hkCategoryTypeConverter(rawValue: String) -> HKCategoryType? {
        let categoryIdentifier = HKCategoryTypeIdentifier(rawValue: rawValue)
        if let categoryType = HKCategoryType.categoryType(forIdentifier: categoryIdentifier) {
            print("CategoryType identified: \(rawValue)")
            return categoryType
        }

        return nil
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
