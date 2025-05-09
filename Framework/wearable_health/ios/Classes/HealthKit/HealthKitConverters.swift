import HealthKit

public func rawValueConverter(rawValue: String) -> HKObjectType? {
    return toQuantityType(rawValue: rawValue)
}

private func toQuantityType(rawValue: String) -> HKObjectType? {
    let identifier = HKQuantityTypeIdentifier(rawValue: rawValue)
    return HKObjectType.quantityType(forIdentifier: identifier)
}
