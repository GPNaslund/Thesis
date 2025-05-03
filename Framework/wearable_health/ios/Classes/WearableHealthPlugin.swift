import Flutter
import HealthKit
import UIKit

public class WearableHealthPlugin: NSObject, FlutterPlugin {
    let healthStore = HKHealthStore()
    
    private enum CallType: String {
        case getPlatformVersion
        case checkPermissions
        case requestPermissions
        case checkDataStoreAvailability
        case getData
        case unknown
        
        static func fromString(val: String) -> CallType {
            return CallType(rawValue: val) ?? .unknown
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "wearable_health", binaryMessenger: registrar.messenger())
        let instance = WearableHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("WearableHealthPlugin: Received call: \(call.method)")
        let callType: CallType = CallType.fromString(val: call.method)
        
        switch callType {
        case .getPlatformVersion:
            handleGetPlatformVersion(result: result)
        case .checkPermissions:
            handleCheckPermissions(call: call, result: result)
        case .requestPermissions:
            handleRequestPermissions(call: call, result: result)
        case .checkDataStoreAvailability:
            handleCheckAvailability(result: result)
        case .getData:
            handleGetData(call: call, result: result)
        case .unknown:
            print("WearableHealthPlugin: Error - Unknown method call: \(call.method)")
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func handleCheckPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            let request = try CheckPermissionsRequest(arguments: call.arguments)
            
            var grantedTypes: Set<HKObjectType> = []
            for objectType in request.objectTypesToRequest {
                if healthStore.authorizationStatus(for: objectType) == .sharingAuthorized {
                    grantedTypes.insert(objectType)
                }
            }
            print("WearableHealthPlugin [CheckPermissions]: Granted types: \(grantedTypes.map { $0.identifier })")
            
            let response = CheckPermissionsResponse(granted: grantedTypes)
            result(response.toMap())
            
        } catch let error as PermissionsRequestError {
            print("WearableHealthPlugin [CheckPermissions]: Invalid Argument Error - \(error.localizedDescription)")
            result(FlutterError(code: "INVALID_ARGUMENT",
                                message: error.localizedDescription,
                                details: nil))
        } catch {
            print("WearableHealthPlugin [CheckPermissions]: Unexpected Error - \(error.localizedDescription)")
            result(FlutterError(code: "UNEXPECTED_ERROR",
                                message: "An unexpected error occurred while checking permissions: \(error.localizedDescription)",
                                details: nil))
        }
    }
    
    private func handleRequestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            let request = try CheckPermissionsRequest(arguments: call.arguments)
            
            let typesToRead: Set<HKObjectType> = request.objectTypesToRequest
            let typesToWrite: Set<HKSampleType>? = nil
            
            guard !typesToRead.isEmpty || (typesToWrite != nil && !typesToWrite!.isEmpty) else {
                print("WearableHealthPlugin [RequestPermissions]: No valid types to request permissions for.")
                let emptyResponse = RequestPermissionsResponse(granted: [])
                result(emptyResponse.toMap())
                return
            }
            
            print("WearableHealthPlugin [RequestPermissions]: Requesting auth for read types: \(typesToRead.map { $0.identifier })")
            
            healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] (success, error) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("WearableHealthPlugin [RequestPermissions]: HealthKit authorization request failed - \(error.localizedDescription)")
                        result(FlutterError(code: "AUTH_REQUEST_ERROR",
                                            message: "HealthKit authorization request failed: \(error.localizedDescription)",
                                            details: nil))
                        return
                    }
                    
                    print("WearableHealthPlugin [RequestPermissions]: Auth request process completed. Success flag: \(success). Checking actual status...")
                    
                    var actuallyGrantedTypes: Set<HKObjectType> = []
                    for objectType in typesToRead {
                        if self.healthStore.authorizationStatus(for: objectType) == .sharingAuthorized {
                            actuallyGrantedTypes.insert(objectType)
                        }
                    }
                    print("WearableHealthPlugin [RequestPermissions]: Actually granted read permissions: \(actuallyGrantedTypes.map { $0.identifier })")
                    
                    let response = RequestPermissionsResponse(granted: actuallyGrantedTypes)
                    
                    result(response.toMap())
                }
            }
            
        } catch let error as PermissionsRequestError {
            print("WearableHealthPlugin [RequestPermissions]: Invalid Argument Error - \(error.localizedDescription)")
            result(FlutterError(code: "INVALID_ARGUMENT",
                                message: error.localizedDescription,
                                details: nil))
        } catch {
            print("WearableHealthPlugin [RequestPermissions]: Unexpected Error - \(error.localizedDescription)")
            result(FlutterError(code: "UNEXPECTED_ERROR",
                                message: "An unexpected error occurred while requesting permissions: \(error.localizedDescription)",
                                details: nil))
        }
    }
    
    private func handleCheckAvailability(result: @escaping FlutterResult) {
        if HKHealthStore.isHealthDataAvailable() {
            print("WearableHealthPlugin [CheckAvailability]: HealthKit is available.")
            result("available")
        } else {
             print("WearableHealthPlugin [CheckAvailability]: HealthKit is not available.")
            result("unavailable")
        }
    }
    
    private func handleGetData(call: FlutterMethodCall, result: @escaping FlutterResult) {
         let dataCollectionQueue = DispatchQueue(label: "com.wearablehealth.datacollection.serial")
         var collectedData: [[String: Any?]] = []

        do {
            let request = try GetDataRequest(arguments: call.arguments)

            guard !request.objectTypesToQuery.isEmpty else {
                 print("WearableHealthPlugin [GetData]: No valid HealthKit types specified in the request.")
                 let emptyResponse = GetDataResponse(result: [])
                 result(emptyResponse.toMap())
                 return
            }

            print("WearableHealthPlugin [GetData]: Preparing to query for types: \(request.objectTypesToQuery.map { $0.identifier }) between \(request.startDate) and \(request.endDate)")

            let group = DispatchGroup()

            for objectType in request.objectTypesToQuery {
                 guard let sampleType = objectType as? HKSampleType else {
                     print("WearableHealthPlugin [GetData]: Skipping non-sample type: \(objectType.identifier)")
                     continue
                 }

                 group.enter()

                 let predicate = HKQuery.predicateForSamples(withStart: request.startDate, end: request.endDate, options: .strictStartDate)
                 let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

                 let query = HKSampleQuery(
                     sampleType: sampleType,
                     predicate: predicate,
                     limit: HKObjectQueryNoLimit,
                     sortDescriptors: [sortDescriptor]
                 ) { _, samples, error in

                     defer { group.leave() }

                     if let error = error {
                         print("WearableHealthPlugin [GetData]: Error fetching \(sampleType.identifier): \(error.localizedDescription)")
                         return
                     }

                     guard let validSamples = samples, !validSamples.isEmpty else {
                          print("WearableHealthPlugin [GetData]: No samples found for \(sampleType.identifier).")
                         return
                     }

                      print("WearableHealthPlugin [GetData]: Found \(validSamples.count) samples for \(sampleType.identifier). Mapping...")

                     let mappedSamples = validSamples.compactMap { sample in
                         mapHKSampleToDictionary(sample)
                     }

                     if !mappedSamples.isEmpty {
                         dataCollectionQueue.async {
                             collectedData.append(contentsOf: mappedSamples)
                         }
                     }
                 }
                 healthStore.execute(query)
             }

            group.notify(queue: .main) {
                 print("WearableHealthPlugin [GetData]: All queries finished. Total data points collected: \(collectedData.count)")
                 dataCollectionQueue.sync {
                     let response = GetDataResponse(result: collectedData)
                     result(response.toMap())
                 }
            }

        } catch let error as GetDataRequestError {
            print("WearableHealthPlugin [GetData]: Invalid Argument Error - \(error.localizedDescription)")
            result(FlutterError(code: "INVALID_ARGUMENT",
                                message: error.localizedDescription,
                                details: nil))
        } catch {
            print("WearableHealthPlugin [GetData]: Unexpected Error - \(error.localizedDescription)")
            result(FlutterError(code: "UNEXPECTED_ERROR",
                                message: "An unexpected error occurred while getting data: \(error.localizedDescription)",
                                details: nil))
        }
    }
}
