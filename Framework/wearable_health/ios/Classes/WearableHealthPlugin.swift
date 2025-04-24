import Flutter
import HealthKit
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let callType: CallType = CallType.fromString(val: call.method)

        switch callType {
        case .getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
        case .hasPermissions:
            checkHasPermissions(call: call, result: result)
        case .requestPermissions:
            requestPermissions(call, method)
        case .dataStoreAvailability:
            checkDataStoreAvailability(result: result)
        case .unkown:
            fatalError("Not implemented")
        }
    }

    private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let typesToProcess = extractHKDataTypesFromCall(call: call)

        if typesToProcess.isEmpty {
            result(
                FlutterError(
                    code: "NO_TYPES_TO_CHECK", message: "No valid types were provided to check",
                    details: nil))
        } else {
            HKHealthStore().requestAuthorization(toShare: typesToProcess, read: typesToProcess) {
                success, error in
                if success {
                    result(true)
                } else {
                    result(
                        FlutterError(
                            code: "AUTHORIZATION_FAILED", message: "Failed to request permissions",
                            details: error?.localizedDescription))
                }
            }
        }
    }

    private func checkHasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let typesToProcess = extractHKDataTypesFromCall(call: call)

        if typesToProcess.isEmpty {
            result(
                FlutterError(
                    code: "NO_TYPES_TO_CHECK", message: "No valid types were provided to check",
                    details: nil))
        } else {
            let authStatus = HKHealthStore().authorizationStatus(for: typesToProcess)
            switch authStatus {
            case .notDetermined:
                print("Authorization status not determined")
                result(false)
            case .sharingDenied:
                print("Sharing denied")
                result(false)
            case .sharingAuthorized:
                print("Sharing authorized")
                result(true)
            }
        }
    }

    private func extractHKDataTypesFromCall(call: FlutterCall) -> [HKObjectType] {
        guard let healthValueStrings = call.arguments as? [String] else {
            result(
                FlutterError(
                    code: "INVALID_ARGUMENTS", message: "Argument must be a list of strings",
                    details: nil))
            return
        }
        print("Recieved health values: \(healthValueStrings)")
        var typesToProcess: [HKObjectType] = []

        for valueString in healthValueStrings {
            print("Handling: \(valueString)")
            let type = hkObjectConverter(rawValue: valueString)
            if type != nil {
                print("Type found: \(type!)")
                typesToProcess.append(type!)
            } else {
                print("Unknown type: \(valueString)")
            }
        }

        return typesToProcess
    }

    private func hkObjectConverter(rawValue: String) -> HKObjectType? {
        let quantityType = hkQuantityTypeConverter(rawValue: rawValue)
        if quantityType != nil {
            return quantityType
        }

        let categoryType = hkCategoryTypeConverter(rawValue: rawValue)
        if categoryType != nil {
            return categoryType
        }

        let workoutType = hkWorkoutTypeConverter(rawValue: String)
        if workoutType != nil {
            return workoutType
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

    private func hkWorkoutTypeConverter(rawValue: String) -> HKWorkoutType? {
        let workoutIdentifier = HKWorkoutTypeIdentifier(rawValue: rawValue)
        if let workoutType = HKWorkoutType.workoutType(forIdentifier: workoutIdentifier) {
            print("WorkoutType identified: \(rawValue)")
            return workoutType
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
