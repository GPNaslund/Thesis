import Flutter
import HealthKit

/// Handles the authorization requests for HealthKit data access
public class HealthKitPermissionsHandler {
    /// The HealthKit store instance used for requesting permissions
    let healthStore: HKHealthStore

    /// Initializes the handler with a HealthKit store
    /// - Parameter store: The HKHealthStore instance to use for permission requests
    init(_ store: HKHealthStore) {
        healthStore = store
    }

    /// Requests HealthKit permissions for the specified data types
    /// - Parameters:
    ///   - call: The Flutter method call containing data types to request access for
    ///   - result: Callback to return the authorization result or errors to Flutter
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

                        result(true)
                    }
                }

            }
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected arguments to be a Map with string keys", details: nil))
        }
    }
    
    public func redirectToPermissionsSettings(result: @escaping FlutterResult) {
        print("[HealthKitPermissionManager]: Starting redirect to permissions settings")
        
        if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettingsURL) {
                UIApplication.shared.open(appSettingsURL, options: [:]) { success in
                    print("[HealthKitPermissionManager]: Opening app settings success: \(success)")
                    result(success)
                }
                return
            }
        }
        if let healthSettingsURL = URL(string: "App-prefs:root=HEALTH") {
            if UIApplication.shared.canOpenURL(healthSettingsURL) {
                UIApplication.shared.open(healthSettingsURL, options: [:]) { success in
                    print("[HealthKitPermissionManager]: Opening Health settings success: \(success)")
                    result(success)
                }
                return
            }
        }
        
        print("[HealthKitPermissionManager]: Failed to open any settings")
        result(false)
    }
}
