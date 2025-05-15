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
    private static let clientIdPrefixHrv = "SEEDER_HRV_"

    private static let baseBpm: Double = 70.0
    private static let baseBodyTempCelsius: Double = 34.0
    private static let baseDeltaTempCelcius: Double = 0.3

    private let healthStore = HKHealthStore()

    override init() {
        let optionalTypesToInit: [HKQuantityType?] = [
             HKQuantityType.quantityType(forIdentifier: .heartRate),
             HKQuantityType.quantityType(forIdentifier: .bodyTemperature),
             HKQuantityType
                .quantityType(forIdentifier: .heartRateVariabilitySDNN)
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
        let heartRateVariabilitySamples = generateHistoricalHeartRateVariabilityData()

        let allSamples = heartRateSamples + bodyTemperatureSamples + heartRateVariabilitySamples

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
    
    private func generateHistoricalHeartRateVariabilityData() -> [HKQuantitySample] {
        print("Generating historical heart rate variability data...")
        var samples = [HKQuantitySample]()
        
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("Heart rate variability type is unavailable")
            return []
        }
        
        let hrvUnit = HKUnit.secondUnit(with: .milli)
        let overallEndTime = Date()
        let overallStartTime = overallEndTime.addingTimeInterval(-DataSeederPlugin.generationPeriodDays)
        
        var recordStartTime = overallStartTime
        let baseRmssd = 35.0
        
        while recordStartTime < overallEndTime {
            let recordEndTime = min(recordStartTime.addingTimeInterval(DataSeederPlugin.recordIntervalAndDuration), overallEndTime)
            
            if recordStartTime >= recordEndTime || recordEndTime.timeIntervalSince(recordStartTime) < DataSeederPlugin.sampleInterval {
                recordStartTime = recordEndTime
                if recordStartTime >= overallEndTime { break }
                continue
            }
            
            let timeVariation = Double(abs(Int(recordStartTime.timeIntervalSince1970) % 15 - 7))
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: recordStartTime)
            let dailyVariation: Double
            switch hour {
            case 0..<6:
                dailyVariation = 10.0
            case 6..<12:
                dailyVariation = 5.0
            case 12..<18:
                dailyVariation = -5.0
            default:
                dailyVariation = 0.0
            }
            
            let weekday = calendar.component(.weekday, from: recordStartTime)
            let weeklyVariation = (weekday > 5) ? 3.0 : -1.0
            
            var rmssd = baseRmssd + timeVariation + dailyVariation + weeklyVariation
            rmssd = max(15.0, min(65.0, rmssd))
            
            let quantity = HKQuantity(unit: hrvUnit, doubleValue: rmssd)
            let metadata: [String: Any] = [
                HKMetadataKeyExternalUUID: "\(DataSeederPlugin.clientIdPrefixHrv)\(Int(recordStartTime.timeIntervalSince1970))"
            ]
            
            let sample = HKQuantitySample(
                type: hrvType,
                quantity: quantity,
                start: recordStartTime,
                end: recordStartTime,
                metadata: metadata
            )
            
            samples.append(sample)
            recordStartTime = recordEndTime
        }
        
        print("Generated \(samples.count) heart rate variability samples.")
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
