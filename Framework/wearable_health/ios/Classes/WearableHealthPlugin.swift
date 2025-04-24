import Flutter
import UIKit
import HealthKit

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
            fatalError("Not implemented")
        case .requestPermissions:
            fatalError("Not implemented")
        case .dataStoreAvailability:
            checkDataStoreAvailability(result: result)
        case .unkown:
            fatalError("Not implemented")
        }
    }
    
    private func checkHasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let healthValueStrings = call.arguments as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Argument must be a list of strings", details: nil))
            return
        }
        print("Recieved health values: \(healthValueStrings)")
        
        for valueString in healthValueStrings {
            print("Handling: \(valueString)")
        }
    }
    
    private func hkObjectConverter(rawValue: String) -> HKObjectType? {
        let quantityType = hkQuantityTypeConverter(rawValue: rawValue)
        if (quantityType != nil) {
            return quantityType
        }
        
        let categoryType = hkCategoryTypeConverter(rawValue: rawValue)
        if (categoryType != nil) {
            return categoryType
        }
        
        
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
                result(FlutterError(code: "URL_CREATION_FAILED", message: "Failed to create URL resource", details: "Failed to create URL for checking health app URL"))
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
