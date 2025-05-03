import Foundation

struct GetDataResponse {
    let resultData: [[String: Any?]]

    init(result: [[String: Any?]]) {
        self.resultData = result
    }

    func toMap() -> [String: Any] {
        return ["result": self.resultData]
    }
}
