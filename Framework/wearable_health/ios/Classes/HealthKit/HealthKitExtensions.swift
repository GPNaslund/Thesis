import Foundation
import HealthKit


/// Extension for Date to provide ISO8601 formatting capabilities
extension Date {
    /// Converts a Date to an ISO8601 formatted string with fractional seconds
   /// - Returns: ISO8601 formatted string representation of the date
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

/// Extension for HKQuantityType to provide standard unit conversions
extension HKQuantityType {
    /// Returns the appropriate standardized unit for supported HealthKit quantity types
    /// - Returns: The standard HKUnit for the quantity type, or nil if type is unsupported
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
