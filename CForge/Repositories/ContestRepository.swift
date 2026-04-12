//
//  ContestRepository.swift
//  CForge
//
//  Created by Harshit Raj on 12/04/26.
//

import Foundation

actor ContestRepository {
    private let service: ContestServiceProtocol
    private var cache: [CFContest]?
    private var lastFetch: Date?
    private let expirationInterval: TimeInterval = 300
    
    private var ongoingTask: Task<[CFContest], Error>?
    
    init(service: ContestServiceProtocol = ContestService()) {
        self.service = service
    }
    
    func getContests(forceRefresh: Bool = false) async throws -> [CFContest] {
        if !forceRefresh, let cache = cache, let lastFetch = lastFetch {
            if Date().timeIntervalSince(lastFetch) < expirationInterval {
                AppLog.debug("ContestRepository: Returning cached data.", category: .cache)
                return cache
            } else {
                AppLog.debug("ContestRepository: Cache expired. Fetching fresh data.", category: .cache)
            }
        }
        
        if let existingTask = ongoingTask {
            AppLog.debug("ContestRepository: Joining ongoing fetch task.", category: .network)
            return try await existingTask.value
        }
        
        let task = Task<[CFContest], Error> {
            do {
                let contests = try await service.fetchContests()
                
                self.cache = contests
                self.lastFetch = Date()
                self.ongoingTask = nil
                return contests
            } catch {
                self.ongoingTask = nil
                throw error
            }
        }
        ongoingTask = task
        return try await task.value
    }
}
