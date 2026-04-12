import Foundation

protocol ContestServiceProtocol {
    func fetchContests() async throws -> [CFContest]
}

final class ContestService: ContestServiceProtocol {
    func fetchContests() async throws -> [CFContest] {
        let urlString = "\(Constants.codeforcesBaseURL)contest.list"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        AppLog.debug("Fetching contests from \(urlString)", category: .network)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = NSError(domain: "Invalid Response", code: 0)
            AppLog.error("Transport error: Invalid HTTP response", category: .network)
            throw NetworkError.transportError(wrapped: error)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            AppLog.error("Server error: \(httpResponse.statusCode)", category: .network)
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(CFContestResponse.self, from: data)
            guard decoded.status == "OK" else {
                let message = decoded.comment ?? "Unknown API error"
                AppLog.error("API Error: \(message)", category: .network)
                throw NetworkError.apiError(message: message)
            }
            return decoded.result ?? []
        } catch {
            AppLog.error("Decoding error: \(error)", category: .network)
            throw NetworkError.decodingError(wrapped: error)
        }
    }
}
