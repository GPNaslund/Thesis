import Flutter
import UIKit

public class DataSeederPlugin: NSObject, FlutterPlugin {
  let dataTypes: Set = [HKQuantityType.quantityType(forIdentifier: .heartRate), HKQuantityType.quantityType(forIdentifier: .bodyTemperature)]
  private static let generationPeriodDays: TimeInterval = 7 * 24 * 60 * 60
	private static let recordIntervalAndDuration: TimeInterval = 15 * 60
	private static let sampleInterval: TimeInterval = 1 * 60

	private static let clientIdPrefixHr = "SEEDER_HR_"
	private static let clientIdPrefixBodyTemp = "SEEDER_BODY_TEMP_"

	private static let baseBpm: Double = 70.0
	private static let baseBodyTempCelsius: Double = 34.0
	private static let baseDeltaTempCelcius: Double = 0.3

	private let healthStore = HKHealthStore()

  
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "data_seeder", binaryMessenger: registrar.messenger())
    let instance = DataSeederPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "hasPermisssions":
      checkHasPermissions(call, result)
    case "requestPermissions":
      requestPermissions(call, result)
    case "seedData":
      result.notImplemented()
    default:
      result(FlutterMethodNotImplemented)
    }
  }

	private func seedData(result: @escaping FlutterResult) {
		let heartRateSamples = generateHistoricalHeartRateData()
		let bodyTemperatureSamples = generateHistoricalBodyTemperatureData()

		let allSamples = heartRateSamples + bodyTempSamples

		guard !allSamples.isEmpty else {
			print("No data generated to save")
			result(false)
		}

		do {
			try await healthStore.save()
			print("Successfully saved \(allSamples.count) samples to HealthKit")
			result(true)
		} catch {
			print("Error saving generated data to HealthKit: \(error.localizedDescription)")
		}
	}


  private func requestPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {      
      if HKHealthStore.isHealthDataAvailable() {
          healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: dataTypes) {
              (success: Bool, error: Error?) in
              if success {
                  print("HealthKit authorization request succeeded")
                  result(true)
              } else {
                  print(
                      "HealthKit authorization failed: \(error?.localizedDescription ?? "by User action")"
                  )
                  result(false)
              }
          }
      }
  }


  private func checkHasPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
      var allIsPermitted = true
      dataTypes.forEach { type in
          if allIsPermitted {
              let authStatus = healthStore.authorizationStatus(for: type)
              if authStatus != .sharingAuthorized {
                  allIsPermitted = false
              }
          }
      }
      result(allIsPermitted)
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
		let overallStartTime = overallEndTime.addingTimeInterval(-generationPeriodDays)
		let recordStartTime = overallStartTime

		while recordStartTime < overallEndTime {
            let recordEndTime = min(recordStartTime.addingTimeInterval(recordIntervalAndDuration), overallEndTime)

            if recordStartTime == recordEndTime || recordEndTime.timeIntervalSince(recordStartTime) <= sampleInterval {
                if recordStartTime >= overallEndTime { break }
                recordStartTime = recordEndTime
                continue
            }

            var sampleTime = recordStartTime.addingTimeInterval(sampleInterval)

            while sampleTime < recordEndTime {
                let epochSeconds = Int(sampleTime.timeIntervalSince1970)
                let variation = abs(epochSeconds % 10 - 5)
                let bpmValue = baseBpm + Double(variation)
                let quantity = HKQuantity(unit: heartRateUnit, doubleValue: bpmValue)

                let metadata: [String: Any] = [
                    HKMetadataKeyExternalUUID: "\(clientIdPrefixHr)\(Int(recordStartTime.timeIntervalSince1970))"
                ]

                let sample = HKQuantitySample(
                    type: heartRateType,
                    quantity: quantity,
                    start: sampleTime,
                    end: sampleTime,
                    metadata: metadata
                )
                samples.append(sample)
                sampleTime = sampleTime.addingTimeInterval(sampleInterval)
            }
            recordStartTime = recordEndTime
        }
        print("Generated \(samples.count) heart rate samples.")
        return samples
	}

	static func generateHistoricalBodyTemperatureData() -> [HKQuantitySample] {
        print("Generating historical body temperature data...")
        var samples = [HKQuantitySample]()

        guard let bodyTemperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature) else {
            print("Body temperature type is unavailable.")
            return []
        }
        let bodyTemperatureUnit = HKUnit.degreeCelsius()

        let overallEndTime = Date()
        let overallStartTime = overallEndTime.addingTimeInterval(-generationPeriodDays)
        var recordStartTime = overallStartTime
        let calendar = Calendar.current

        while recordStartTime < overallEndTime {
            let recordEndTime = min(recordStartTime.addingTimeInterval(recordIntervalAndDuration), overallEndTime)

            if recordStartTime == recordEndTime || recordEndTime.timeIntervalSince(recordStartTime) <= sampleInterval {
                if recordStartTime >= overallEndTime { break }
                recordStartTime = recordEndTime
                continue
            }

            var sampleTime = recordStartTime.addingTimeInterval(sampleInterval)

            while sampleTime < recordEndTime {
                let minuteOfHour = calendar.component(.minute, from: sampleTime)
                let variation = Double(minuteOfHour) * 0.005
                let tempValue = baseBodyTempCelsius + baseDeltaTempCelsius + variation
                let quantity = HKQuantity(unit: bodyTemperatureUnit, doubleValue: tempValue)

                let metadata: [String: Any] = [
                    HKMetadataKeyExternalUUID: "\(clientIdPrefixBodyTemp)\(Int(recordStartTime.timeIntervalSince1970))"
                ]

                let sample = HKQuantitySample(
                    type: bodyTemperatureType,
                    quantity: quantity,
                    start: sampleTime,
                    end: sampleTime,  
                    metadata: metadata
                )
                samples.append(sample)
                sampleTime = sampleTime.addingTimeInterval(sampleInterval)
            }
            recordStartTime = recordEndTime
        }
        print("Generated \(samples.count) body temperature samples.")
        return samples
    }

}
