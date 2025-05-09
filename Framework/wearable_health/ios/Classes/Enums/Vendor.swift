enum Vendor: String {
    case healthKit
    case unknown
    
    
    static func fromString(val: String) -> Vendor {
        return Vendor(rawValue: val) ?? .unknown
    }
}

