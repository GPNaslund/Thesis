import Flutter
import HealthKit

/// Main manager class that coordinates HealthKit operations for the Flutter plugin
public class HealthKitManager {
    /// The HealthKit store instance used for all health data operations
    let healthStore: HKHealthStore
    // Handler for managing HealthKit permissions requests
    let permissionsHandler: HealthKitPermissionsHandler

    // Handler for retrieving and processing HealthKit data
    let dataHandler: HealthKitDataHandler

    /// Initializes the manager with required components
    /// - Parameters:
    ///   - store: The HKHealthStore instance to use for data access
    ///   - pHandler: Handler for permission-related operations
    ///   - dHandler: Handler for data retrieval operations
    init(
        _ store: HKHealthStore,
        _ pHandler: HealthKitPermissionsHandler,
        _ dHandler: HealthKitDataHandler
    ) {
        healthStore = store
        permissionsHandler = pHandler
        dataHandler = dHandler
    }

    /// Processes method calls from Flutter and routes them to appropriate handlers
    /// - Parameters:
    ///   - call: The Flutter method call containing method name and arguments
    ///   - result: Callback to return the operation result or errors to Flutter
    public func methodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[HealthKitManager] received call \(call.method)")
        let callType: CallType = CallType
            .fromString(val: call.method.components(separatedBy: "/")[1])

        switch callType {
        case .platformVersion:
            getPlatformVersion(result: result)
        case .requestPermissions:
            permissionsHandler.requestPermissions(call: call, result: result)
        case .checkDataStoreAvailability:
            checkAvailability(result: result)
        case .getData:
            dataHandler.getData(call: call, result: result)
        case .redirectToPermissionsSettings:
            permissionsHandler.redirectToPermissionsSettings(result: result)
        case .unknown:
            print("[HealthKitManager] Error - Unknown method call: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }

    /// Returns the current iOS platform version
    /// - Parameter result: Callback to return the platform version
    private func getPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }

    /// Checks if HealthKit data is available on the device
    /// - Parameter result: Callback to return "available" or "unavailable"
    private func checkAvailability(result: @escaping FlutterResult) {
        if HKHealthStore.isHealthDataAvailable() {
            print("[HealthKitManager]: HealthKit is available.")
            result("available")
        } else {
            print("[HealthKitManager]: HealthKit is not available.")
            result("unavailable")
        }
    }
}
