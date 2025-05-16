import Flutter
import HealthKit
import UIKit

/// Main Flutter plugin class that serves as the entry point for all health data operations
public class WearableHealthPlugin: NSObject, FlutterPlugin {
    /// The primary HealthKit store instance used throughout the plugin
    let healthStore = HKHealthStore()

    /// Lazily initialized handler for HealthKit permissions requests
    lazy var hkPermissionsHandler: HealthKitPermissionsHandler = {
        return HealthKitPermissionsHandler(self.healthStore)
    }()

    /// Lazily initialized handler for HealthKit data retrieval operations
    lazy var hkDataHandler: HealthKitDataHandler = {
        return HealthKitDataHandler(self.healthStore)
    }()

    /// Lazily initialized manager that coordinates all HealthKit operations
    lazy var hkManager: HealthKitManager = {
        return HealthKitManager(
            self.healthStore,
            self.hkPermissionsHandler,
            self.hkDataHandler
        )
    }()

    /// Registers this plugin with the Flutter engine
    /// - Parameter registrar: The plugin registrar used to set up method channels
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls from Flutter and routes them to appropriate handlers
    /// - Parameters:
    ///   - call: The Flutter method call containing vendor identifier and method name
    ///   - result: Callback to return the operation result or errors to Flutter
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[WearableHealthPlugin] Received call: \(call.method)")
        let vendor: Vendor = Vendor.fromString(
            val: call.method.components(separatedBy: "/")[0]
        )

        switch vendor {
        case .healthKit:
            hkManager.methodCall(call, result: result)
        case .unknown:
            print("[WearableHealthPlugin] Error - Unknown vendor call: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }


}
