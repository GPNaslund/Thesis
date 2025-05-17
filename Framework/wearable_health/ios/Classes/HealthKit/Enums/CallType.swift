/// Represents different types of method calls or operations in the Flutter plugin
enum CallType: String {
    /// Call to retrieve the platform version information
    case platformVersion
    /// Call to request health data access permissions from the user
    case requestPermissions
    /// Call to verify if the health data store is accessible and available
    case checkDataStoreAvailability
    /// Call to fetch health data from the device
    case getData
    case redirectToPermissionsSettings
    /// Represents an unrecognized or unsupported call type
    case unknown

    /// Creates a CallType from a string representation
    /// - Parameter val: String value to convert to a CallType
    /// - Returns: The matching CallType or .unknown if no match found
    static func fromString(val: String) -> CallType {
        return CallType(rawValue: val) ?? .unknown
    }
}
