enum CallType: String {
    case platformVersion
    case checkPermissions
    case requestPermissions
    case checkDataStoreAvailability
    case getData
    case unknown

    static func fromString(val: String) -> CallType {
        return CallType(rawValue: val) ?? .unknown
    }
}
