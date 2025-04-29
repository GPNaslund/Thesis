enum CallType: String {
    case getPlatformVersion = "getPlatformVersion"
    case hasPermissions = "hasPermissions"
    case requestPermissions = "requestPermissions"
    case dataStoreAvailability = "dataStoreAvailability"
    case getData = "getData"
    case unkown = "unkown"

    static func fromString(val: String) -> CallType {
        switch val {
        case "getPlatformVersion":
            return .getPlatformVersion
        case "hasPermissions":
            return .hasPermissions
        case "requestPermissions":
            return .requestPermissions
        case "dataStoreAvailability":
            return .dataStoreAvailability
        case "getData":
            return .getData
        default:
            return .unkown
        }
    }
}
