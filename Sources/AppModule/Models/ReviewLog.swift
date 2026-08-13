import Foundation
import SwiftData

@Model
final class ReviewLog {
    var date: Date

    init(date: Date = Date()) {
        self.date = date
    }
}
