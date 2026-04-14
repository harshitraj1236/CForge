import Foundation

struct CFContest: Identifiable, Codable {
    let id: Int
    let name: String
    let type: String
    let phase: String
    let durationSeconds: Int
    let startTimeSeconds: Int?
    var registrationUrl: URL? {
        URL(string: "https://codeforces.com/contestRegistration/\(id)")
    }
    
    var contestUrl: URL? {
        URL(string: "https://codeforces.com/contest/\(id)")
    }
    
    var isRated: Bool {
        return type.lowercased().contains("rated") || name.lowercased().contains("rated")
    }
    
    var startTime: Date {
        Date(timeIntervalSince1970: TimeInterval(startTimeSeconds ?? 0))
    }
    
    var duration: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var countdownTitle: String {
        switch phase.uppercased() {
        case "BEFORE":
            return "Starts in"
        case "CODING":
            return "Live now"
        default:
            return "Contest status"
        }
    }

    var countdownValue: String {
        switch phase.uppercased() {
        case "BEFORE":
            return startTime.timeRemainingString()
        case "CODING":
            return "Running"
        default:
            return "Ended"
        }
    }
}

struct CFContestResponse: Codable {
    let status: String
    let result: [CFContest]?
    let comment: String?
}
