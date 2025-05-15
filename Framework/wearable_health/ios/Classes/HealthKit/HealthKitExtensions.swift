import Foundation
import HealthKit


extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

extension HKQuantityType {
     func getStandardUnit() -> HKUnit? {
         let identifier = self.identifier
         switch identifier {
         case HKQuantityTypeIdentifier.heartRate.rawValue:
             return HKUnit.count().unitDivided(by: .minute())
          case HKQuantityTypeIdentifier.bodyTemperature.rawValue:
                return .degreeCelsius()
         case HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue:
             return .secondUnit(with: .milli)
         default:
             print("Warning [getStandardUnit]: Called for an unsupported quantity type: \(identifier).")
             return nil
         }
     }
}
