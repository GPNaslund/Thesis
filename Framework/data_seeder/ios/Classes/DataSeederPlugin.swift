import Flutter
import UIKit
import HealthKit

public class DataSeederPlugin: NSObject, FlutterPlugin {

    private let dataTypes: [HKQuantityType]
    private let typesToShare: Set<HKSampleType>
    private let typesToRead: Set<HKObjectType>

    private static let generationPeriodDays: TimeInterval = 7 * 24 * 60 * 60
    private static let recordIntervalAndDuration: TimeInterval = 15 * 60
    private static let sampleInterval: TimeInterval = 1 * 60

    private static let clientIdPrefixHr = "SEEDER_HR_"
    private static let clientIdPrefixBodyTemp = "SEEDER_BODY_TEMP_"

    private static let baseBpm: Double = 70.0
    private static let baseBodyTempCelsius: Double = 34.0
    private static let baseDeltaTempCelcius: Double = 0.3

    private let healthStore = HKHealthStore()

    override init() {
        let optionalTypesToInit: [HKQuantityType?] = [
             HKQuantityType.quantityType(forIdentifier: .heartRate),
             HKQuantityType.quantityType(forIdentifier: .bodyTemperature)
        ]
        dataTypes = optionalTypesToInit.compactMap { $0 }
        typesToShare = Set<HKSampleType>(dataTypes)
        typesToRead = Set<HKObjectType>(dataTypes)

        super.init()
    }


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "data_seeder", binaryMessenger: registrar.messenger())
        let instance = DataSeederPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "hasPermissions":
            checkHasPermissions(result: result)
        case "requestPermissions":
            requestPermissions(result: result)
        case "seedData":
            seedData(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func seedData(result: @escaping FlutterResult) {
        let heartRateSamples = generateHistoricalHeartRateData()
        let bodyTemperatureSamples = generateHistoricalBodyTemperatureData()

        let allSamples = heartRateSamples + bodyTemperatureSamples

        guard !allSamples.isEmpty else {
            print("No data generated to save")
            result(false)
            return
        }

        healthStore.save(allSamples) { (success, error) in
            if success {
                print("Successfully saved \(allSamples.count) samples to HealthKit")
                result(true)
            } else {
                print("Error saving generated data to HealthKit: \(error?.localizedDescription ?? "Unknown error")")
                result(false)
            }
        }
    }


    private func requestPermissions(result: @escaping FlutterResult) {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) {
                (success: Bool, error: Error?) in
                DispatchQueue.main.async {
                    if success {
                        print("HealthKit authorization request finished (Success=\(success))")
                        result(true)
                    } else {
                        print(
                            "HealthKit authorization request failed: \(error?.localizedDescription ?? "Possibly denied by User")"
                        )
                        result(false)
                    }
                }
            }
        } else {
            print("Health data is not available on this device.")
            DispatchQueue.main.async {
                result(false)
            }
        }
    }


    private func checkHasPermissions(result: @escaping FlutterResult) {
        var hasAllReadPermissions = true
        for type in dataTypes {
            let authStatus = healthStore.authorizationStatus(for: type)
            if authStatus != .sharingAuthorized {
                hasAllReadPermissions = false
                break
            }
        }
        print("Checked read permissions: \(hasAllReadPermissions)")
        result(hasAllReadPermissions)
    }

    private func generateHistoricalHeartRateData() -> [HKQuantitySample] {
        print("Generating historical heart rate data..")
        var samples = [HKQuantitySample]()

        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Heart rate type is unavailable")
            return []
        }

        let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
        let overallEndTime = Date()
        let overallStartTime = overallEndTime.addingTimeInterval(-DataSeederPlugin.generationPeriodDays)

        var recordStartTime = overallStartTime

        while recordStartTime < overallEndTime {
            let recordEndTime = min(recordStartTime.addingTimeInterval(DataSeederPlugin.recordIntervalAndDuration), overallEndTime)

            if recordStartTime >= recordEndTime || recordEndTime.timeIntervalSince(recordStartTime) < DataSeederPlugin.sampleInterval {
                recordStartTime = recordEndTime
                if recordStartTime >= overallEndTime { break }
                continue
            }

            var sampleTime = recordStartTime.addingTimeInterval(DataSeederPlugin.sampleInterval)

            while sampleTime < recordEndTime {
                let epochSeconds = Int(sampleTime.timeIntervalSince1970)
                let variation = Double(abs(epochSeconds % 10 - 5))
                let bpmValue = DataSeederPlugin.baseBpm + variation
                let quantity = HKQuantity(unit: heartRateUnit, doubleValue: bpmValue)

                let metadata: [String: Any] = [
                    HKMetadataKeyExternalUUID: "\(DataSeederPlugin.clientIdPrefixHr)\(Int(recordStartTime.timeIntervalSince1970))_\(epochSeconds)"
                ]

                let sample = HKQuantitySample(
                    type: heartRateType,
                    quantity: quantity,
                    start: sampleTime,
                    end: sampleTime,
                    metadata: metadata
                )
                samples.append(sample)
                sampleTime = sampleTime.addingTimeInterval(DataSeederPlugin.sampleInterval)
            }
            recordStartTime = recordEndTime
        }
        print("Generated \(samples.count) heart rate samples.")
        return samples
    }

    private func generateHistoricalBodyTemperatureData() -> [HKQuantitySample] {
        print("Generating historical body temperature data...")
        var samples = [HKQuantitySample]()

        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            print("Body temperature type is unavailable.")
            return []
        }
        let bodyTemperatureUnit = HKUnit.degreeCelsius()

        let overallEndTime = Date()
        let overallStartTime = overallEndTime.addingTimeInterval(-DataSeederPlugin.generationPeriodDays)
        var recordStartTime = overallStartTime
        let calendar = Calendar.current

        while recordStartTime < overallEndTime {
            let recordEndTime = min(recordStartTime.addingTimeInterval(DataSeederPlugin.recordIntervalAndDuration), overallEndTime)

            if recordStartTime >= recordEndTime || recordEndTime.timeIntervalSince(recordStartTime) < DataSeederPlugin.sampleInterval {
                 recordStartTime = recordEndTime
                 if recordStartTime >= overallEndTime { break }
                 continue
            }

            var sampleTime = recordStartTime.addingTimeInterval(DataSeederPlugin.sampleInterval)

            while sampleTime < recordEndTime {
                let minuteOfHour = calendar.component(.minute, from: sampleTime)
                let variation = Double(minuteOfHour) * 0.005
                let tempValue = DataSeederPlugin.baseBodyTempCelsius + DataSeederPlugin.baseDeltaTempCelcius + variation
                let quantity = HKQuantity(unit: bodyTemperatureUnit, doubleValue: tempValue)

                 let epochSeconds = Int(sampleTime.timeIntervalSince1970)
                 let metadata: [String: Any] = [
                    HKMetadataKeyExternalUUID: "\(DataSeederPlugin.clientIdPrefixBodyTemp)\(Int(recordStartTime.timeIntervalSince1970))_\(epochSeconds)"
                ]

                let sample = HKQuantitySample(
                    type: bodyTemperatureType,
                    quantity: quantity,
                    start: sampleTime,
                    end: sampleTime,
                    metadata: metadata
                )
                samples.append(sample)
                sampleTime = sampleTime.addingTimeInterval(DataSeederPlugin.sampleInterval)
            }
            recordStartTime = recordEndTime
        }
        print("Generated \(samples.count) body temperature samples.")
        return samples
    }
}
