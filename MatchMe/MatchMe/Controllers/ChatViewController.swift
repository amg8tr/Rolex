import UIKit

class ChatViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private var activeMatches: [Match] = []
    private var filteredMatches: [Match] = []
    private var isSearching = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search conversations"
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No active chats.\nStart matching to begin conversations!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChats()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Chats"
        
        // Add search controller
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func loadChats() {
        activeMatches = dataManager.getActiveMatches()
        filteredMatches = activeMatches
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let matchesToShow = isSearching ? filteredMatches : activeMatches
        emptyStateLabel.isHidden = !matchesToShow.isEmpty
        tableView.isHidden = matchesToShow.isEmpty
        
        if isSearching && filteredMatches.isEmpty {
            emptyStateLabel.text = "No chats found"
        } else if activeMatches.isEmpty {
            emptyStateLabel.text = "No active chats.\nStart matching to begin conversations!"
        }
    }
    
    private func getUserNames(for match: Match) -> String {
        let participantNames = match.participants.compactMap { userId in
            if userId == dataManager.currentUser?.id {
                return "You"
            } else {
                return dataManager.availableUsers.first { $0.id == userId }?.name
            }
        }
        return participantNames.joined(separator: " & ")
    }
    
    private func getLastMessage(for match: Match) -> String {
        let messages = dataManager.getMessages(for: match.id)
        return messages.last?.message ?? "Start the conversation!"
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMatches.count : activeMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatTableViewCell
        let match = isSearching ? filteredMatches[indexPath.row] : activeMatches[indexPath.row]
        cell.configure(
            with: match,
            userNames: getUserNames(for: match),
            lastMessage: getLastMessage(for: match)
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let match = isSearching ? filteredMatches[indexPath.row] : activeMatches[indexPath.row]
        
        // Navigate to chat detail
        let chatVC = ChatDetailViewController(match: match)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension ChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            filteredMatches = activeMatches
            tableView.reloadData()
            updateEmptyState()
            return
        }
        
        isSearching = true
        filteredMatches = activeMatches.filter { match in
            // Search by participant names
            let userNames = getUserNames(for: match).lowercased()
            if userNames.contains(searchText.lowercased()) {
                return true
            }
            
            // Search by message content
            let messages = dataManager.getMessages(for: match.id)
            return messages.contains { $0.message.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
        updateEmptyState()
    }
}

// MARK: - UISearchBarDelegate

extension ChatViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredMatches = activeMatches
        tableView.reloadData()
        updateEmptyState()
    }
} 