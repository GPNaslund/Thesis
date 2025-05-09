import Flutter
import HealthKit
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    let healthStore = HKHealthStore()
    
    lazy var hkPermissionsHandler: HealthKitPermissionsHandler = {
        return HealthKitPermissionsHandler(self.healthStore)
    }()
    
    lazy var hkDataHandler: HealthKitDataHandler = {
        return HealthKitDataHandler(self.healthStore)
    }()
    
    
    lazy var hkManager: HealthKitManager = {
        return HealthKitManager(
            self.healthStore,
            self.hkPermissionsHandler,
            self.hkDataHandler
        )
    }()
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
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
