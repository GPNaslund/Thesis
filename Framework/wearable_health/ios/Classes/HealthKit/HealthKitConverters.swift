import HealthKit

/// Converts a string raw value to an appropriate HealthKit object type
/// - Parameter rawValue: String identifier for the desired HealthKit type
/// - Returns: The corresponding HKObjectType if conversion is successful, nil otherwise
public func rawValueConverter(rawValue: String) -> HKObjectType? {
    return toQuantityType(rawValue: rawValue)
}

/// Attempts to convert a string raw value to a HealthKit quantity type
/// - Parameter rawValue: String identifier corresponding to an HKQuantityTypeIdentifier
/// - Returns: The HKObjectType for the specified quantity type, or nil if invalid
private func toQuantityType(rawValue: String) -> HKObjectType? {
    let identifier = HKQuantityTypeIdentifier(rawValue: rawValue)
    return HKObjectType.quantityType(forIdentifier: identifier)
}
