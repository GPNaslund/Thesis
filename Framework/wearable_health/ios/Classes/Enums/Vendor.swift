/// Represents the source or vendor of health data
enum Vendor: String {
    /// Data sourced from Apple HealthKit
    case healthKit
    /// Data from an unidentified or unsupported source
    case unknown

    /// Creates a Vendor from a string representation
    /// - Parameter val: String value to convert to a Vendor
    /// - Returns: The matching Vendor type or .unknown if no match found
    static func fromString(val: String) -> Vendor {
        return Vendor(rawValue: val) ?? .unknown
    }
}
