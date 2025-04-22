public enum CallType: String {
    case getPlatformVersion = "getPlatformVersion"
    case hasPermission = "hasPermission"
    case requestPermission = "requestPermissions"
    case dataStoreAvailability = "dataStoreAvailability"

    static func fromString(val: String) -> CallType? {
        switch val {
        case "getPlatformVersion":
            return .getPlatformVersion
        case "hasPermission":
            return .hasPermission
        case "requestPermissions":
            return .requestPermission
        case "dataStoreAvailability":
            return .dataStoreAvailability
        default:
            return nil
        }
    }
}
