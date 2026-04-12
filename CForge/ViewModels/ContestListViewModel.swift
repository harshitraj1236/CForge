//
//  ContestListViewModel.swift
//  CForge
//
//  Created by Harshit Raj on 12/04/26.
//

import Foundation

@MainActor
final class ContestListViewModel: ObservableObject {
    enum ViewState {
        case idle, loading, loaded([CFContest]), error(String)
    }
    
    @Published var state: ViewState = .idle
    @Published var searchText: String = ""
    
    private let repository: ContestRepository
    private var allContests: [CFContest] = []
    
    init(repository: ContestRepository = ContestRepository()) {
        self.repository = repository
    }
    
    var filteredContests: [CFContest] {
        allContests
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    func loadContests(forceRefresh: Bool = false) async {
        if case .loading = state { return }
        
        state = .loading
        AppLog.debug("ViewModel: Loading contests (Force: \(forceRefresh))", category: .ui)
        do {
            allContests = try await repository.getContests(forceRefresh: forceRefresh)
            state = .loaded(allContests)
            AppLog.debug("ViewModel: Contests loaded. Count: \(allContests.count)", category: .ui)
        } catch {
            let message: String
            if let netError = error as? NetworkError {
                message = netError.errorDescription ?? "Unknown network error"
            } else {
                message = error.localizedDescription
            }
            AppLog.error("ViewModel: Load Error - \(message)", category: .ui)
            state = .error(message)
        }
    }
}
