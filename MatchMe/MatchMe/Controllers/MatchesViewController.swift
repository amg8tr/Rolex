import UIKit

class MatchesViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private var activeMatches: [Match] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MatchTableViewCell.self, forCellReuseIdentifier: "MatchCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No active matches yet.\nStart swiping to find matches!"
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
        loadMatches()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Matches"
        
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
    
    private func loadMatches() {
        activeMatches = dataManager.getActiveMatches()
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !activeMatches.isEmpty
        tableView.isHidden = activeMatches.isEmpty
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
    
    private func showChallengeCreation(for match: Match) {
        let alert = UIAlertController(title: "Create Challenge", message: "What type of challenge would you like to create?", preferredStyle: .actionSheet)
        
        Challenge.ChallengeType.allCases.forEach { challengeType in
            alert.addAction(UIAlertAction(title: challengeType.displayName, style: .default) { _ in
                self.createChallenge(for: match, type: challengeType)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func createChallenge(for match: Match, type: Challenge.ChallengeType) {
        let alert = UIAlertController(title: "Create \(type.displayName) Challenge", message: "Enter your challenge details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Challenge title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Challenge description"
        }
        
        alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let description = alert.textFields?[1].text, !description.isEmpty else {
                return
            }
            
            let challenge = self.dataManager.createChallenge(title: title, description: description, type: type)
            
            // Navigate to challenge detail
            let challengeVC = ChallengeDetailViewController(challenge: challenge, match: match)
            self.navigationController?.pushViewController(challengeVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MatchesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activeMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchTableViewCell
        let match = activeMatches[indexPath.row]
        cell.configure(with: match, userNames: getUserNames(for: match))
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MatchesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let match = activeMatches[indexPath.row]
        
        // Navigate to chat
        let chatVC = ChatDetailViewController(match: match)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let match = activeMatches[indexPath.row]
        
        // Only show rate action for 1-on-1 matches
        guard match.participants.count == 2 else { return nil }
        
        let rateAction = UIContextualAction(style: .normal, title: "Rate Date") { [weak self] _, _, completionHandler in
            self?.showDateRating(for: match)
            completionHandler(true)
        }
        rateAction.backgroundColor = .systemPink
        rateAction.image = UIImage(systemName: "star.fill")
        
        return UISwipeActionsConfiguration(actions: [rateAction])
    }
    
    private func showDateRating(for match: Match) {
        // Find the other user in the match
        guard let otherUserId = match.participants.first(where: { $0 != dataManager.currentUser?.id }),
              let otherUser = dataManager.availableUsers.first(where: { $0.id == otherUserId }) else {
            return
        }
        
        let dateScoreVC = DateScoreViewController(match: match, otherUser: otherUser)
        dateScoreVC.delegate = self
        let navController = UINavigationController(rootViewController: dateScoreVC)
        present(navController, animated: true)
    }
}

// MARK: - DateScoreViewControllerDelegate

extension MatchesViewController: DateScoreViewControllerDelegate {
    func dateScoreViewController(_ controller: DateScoreViewController, didScore score: Int, comment: String?) {
        controller.dismiss(animated: true) {
            // Show thank you message
            let alert = UIAlertController(
                title: "Rating Submitted",
                message: score >= 7 ? "Glad you had a great time! 🎉" : "Thanks for your feedback!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - MatchTableViewCellDelegate

extension MatchesViewController: MatchTableViewCellDelegate {
    func matchTableViewCell(_ cell: MatchTableViewCell, didTapChallengeButton match: Match) {
        if match.participants.count > 2 {
            // Navigate to group challenge view
            if let challenge = dataManager.challenges.first(where: { $0.id == match.challengeId }) {
                let groupChallengeVC = GroupChallengeViewController(match: match, challenge: challenge)
                navigationController?.pushViewController(groupChallengeVC, animated: true)
            }
        } else {
            showChallengeCreation(for: match)
        }
    }
} 