import Flutter
import HealthKit

public class HealthKitManager {
    let healthStore: HKHealthStore
    let permissionsHandler: HealthKitPermissionsHandler
    let dataHandler: HealthKitDataHandler
    
    init(
        _ store: HKHealthStore,
        _ pHandler: HealthKitPermissionsHandler,
        _ dHandler: HealthKitDataHandler
    ) {
        healthStore = store
        permissionsHandler = pHandler
        dataHandler = dHandler
    }
    
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
        case .unknown:
            print("[HealthKitManager] Error - Unknown method call: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
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

