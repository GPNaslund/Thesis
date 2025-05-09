import Flutter
import HealthKit

public class HealthKitPermissionsHandler {
    let healthStore: HKHealthStore
    
    init(_ store: HKHealthStore) {
        healthStore = store
    }
    
    public func checkPermissions(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        result("Privacy policy restrics the extraction of read rights")
    }
    
    public func requestPermissions(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        if let arguments = call.arguments as? [String: Any] {
            if let types = arguments["types"] as? [String] {
                var typesToRead: Set<HKObjectType> = []
                let typesToWrite: Set<HKSampleType>? = nil
                
                for element in types {
                    if let converted = rawValueConverter(rawValue: element)
                    {
                        typesToRead.insert(converted)
                    }
                }
                
                guard
                    !typesToRead.isEmpty
                        || (typesToWrite != nil && !typesToWrite!.isEmpty)
                else {
                    print(
                        "[HealthKitPermissionsHandler]: No valid types to request permissions for."
                    )
                    result(
                        FlutterError(
                            code: "INVALID_ARGUMENT",
                            message:
                                "No valid types to request permissions for was provided",
                            details: nil))
                    return
                }
                
                print(
                    "[HealthKitPermissionsHandler]: Requesting auth for read types: \(typesToRead.map { $0.identifier })"
                )
                
                healthStore.requestAuthorization(
                    toShare: typesToWrite, read: typesToRead
                ) { [weak self] (success, error) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            print(
                                "[HealthKitPermissionsHandler]: HealthKit authorization request failed - \(error.localizedDescription)"
                            )
                            result(
                                FlutterError(
                                    code: "AUTH_REQUEST_ERROR",
                                    message:
                                        "HealthKit authorization request failed: \(error.localizedDescription)",
                                    details: nil))
                            return
                        }
                        
                        print(
                            "[HealthKitPermissionsHandler]: Auth request process completed. Success flag: \(success). Checking actual status..."
                        )
                        
                        result("Success")
                    }
                }
                
            }
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected arguments to be a Map with string keys", details: nil))
        }
        
    }
}
