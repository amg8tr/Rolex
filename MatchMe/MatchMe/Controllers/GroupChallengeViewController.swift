import UIKit
import AVFoundation

class GroupChallengeViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let match: Match
    private let challenge: Challenge
    private var responses: [ChallengeResponse] = []
    private var participants: [User] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Group Challenge"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var challengeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = challenge.description
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var participantsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var createChallengeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create New Challenge", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createChallengeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(match: Match, challenge: Challenge) {
        self.match = match
        self.challenge = challenge
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadParticipants()
        loadResponses()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Challenge in Progress"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(challengeDescriptionLabel)
        contentView.addSubview(participantsStackView)
        contentView.addSubview(createChallengeButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            challengeDescriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            challengeDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            challengeDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            participantsStackView.topAnchor.constraint(equalTo: challengeDescriptionLabel.bottomAnchor, constant: 30),
            participantsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            participantsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            createChallengeButton.topAnchor.constraint(equalTo: participantsStackView.bottomAnchor, constant: 30),
            createChallengeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            createChallengeButton.widthAnchor.constraint(equalToConstant: 250),
            createChallengeButton.heightAnchor.constraint(equalToConstant: 50),
            createChallengeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func loadParticipants() {
        // Load participants (excluding current user)
        participants = match.participants.compactMap { userId in
            if userId == dataManager.currentUser?.id {
                return nil
            }
            return dataManager.availableUsers.first { $0.id == userId }
        }
        
        // Create participant response cards
        for participant in participants {
            let responseCard = createParticipantResponseCard(for: participant)
            participantsStackView.addArrangedSubview(responseCard)
        }
    }
    
    private func createParticipantResponseCard(for user: User) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 15
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 5
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.name), \(user.age)"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bioLabel = UILabel()
        bioLabel.text = user.bio
        bioLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bioLabel.textColor = .secondaryLabel
        bioLabel.numberOfLines = 2
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let responseLabel = UILabel()
        responseLabel.text = "Waiting for response..."
        responseLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        responseLabel.textColor = .systemGray
        responseLabel.numberOfLines = 0
        responseLabel.translatesAutoresizingMaskIntoConstraints = false
        responseLabel.tag = 100 // Tag to update later
        
        let scoreStackView = UIStackView()
        scoreStackView.axis = .horizontal
        scoreStackView.distribution = .fillEqually
        scoreStackView.spacing = 5
        scoreStackView.translatesAutoresizingMaskIntoConstraints = false
        scoreStackView.isHidden = true // Hide until response is received
        scoreStackView.tag = 200 // Tag to show later
        
        // Create score buttons (1-10)
        for score in 1...10 {
            let scoreButton = UIButton(type: .system)
            scoreButton.setTitle("\(score)", for: .normal)
            scoreButton.backgroundColor = .systemGray5
            scoreButton.layer.cornerRadius = 5
            scoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            scoreButton.tag = score
            scoreButton.addTarget(self, action: #selector(scoreButtonTapped(_:)), for: .touchUpInside)
            scoreStackView.addArrangedSubview(scoreButton)
        }
        
        let recordButton = UIButton(type: .system)
        recordButton.setTitle("📹 View Response", for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.layer.cornerRadius = 10
        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.isHidden = true
        recordButton.tag = 300 // Tag to show for media responses
        
        cardView.addSubview(nameLabel)
        cardView.addSubview(bioLabel)
        cardView.addSubview(responseLabel)
        cardView.addSubview(scoreStackView)
        cardView.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            
            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            bioLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            bioLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            
            responseLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 10),
            responseLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            responseLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            
            recordButton.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 10),
            recordButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            recordButton.widthAnchor.constraint(equalToConstant: 150),
            recordButton.heightAnchor.constraint(equalToConstant: 35),
            
            scoreStackView.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10),
            scoreStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            scoreStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -15),
            scoreStackView.heightAnchor.constraint(equalToConstant: 30),
            scoreStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -15),
            
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])
        
        // Store user ID as tag for reference
        cardView.accessibilityIdentifier = user.id
        
        return cardView
    }
    
    private func loadResponses() {
        // Simulate loading responses (in real app, would fetch from server)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateResponses()
        }
    }
    
    private func simulateResponses() {
        // Create mock responses for each participant
        for (index, participant) in participants.enumerated() {
            let responseTexts = [
                "I would bring a water purifier, a knife, and a satellite phone for emergencies!",
                "Solar panels, fishing gear, and a good book collection would be my choices.",
                "A hammock, matches, and a first aid kit - practical and comfortable!"
            ]
            
            let response = dataManager.addResponse(
                to: challenge.id,
                response: responseTexts[index % responseTexts.count],
                mediaURL: nil
            )
            responses.append(response)
            
            // Update UI for this participant
            if let cardView = participantsStackView.arrangedSubviews.first(where: { $0.accessibilityIdentifier == participant.id }) {
                if let responseLabel = cardView.viewWithTag(100) as? UILabel {
                    responseLabel.text = "Response: \(response.response)"
                    responseLabel.textColor = .label
                }
                if let scoreStackView = cardView.viewWithTag(200) {
                    scoreStackView.isHidden = false
                }
            }
        }
    }
    
    @objc private func scoreButtonTapped(_ sender: UIButton) {
        let score = sender.tag
        
        // Find which participant this score is for
        guard let cardView = sender.superview?.superview,
              let userId = cardView.accessibilityIdentifier,
              let response = responses.first(where: { $0.userId == userId }) else {
            return
        }
        
        // Score the response
        dataManager.scoreResponse(response, score: score)
        
        // Update button appearance
        if let scoreStackView = cardView.viewWithTag(200) as? UIStackView {
            for case let button as UIButton in scoreStackView.arrangedSubviews {
                button.backgroundColor = button.tag == score ? .systemPink : .systemGray5
                button.setTitleColor(button.tag == score ? .white : .systemBlue, for: .normal)
            }
        }
        
        // Check if all responses are scored
        checkIfAllScored()
    }
    
    private func checkIfAllScored() {
        let allScored = responses.allSatisfy { response in
            dataManager.challenges.first { $0.id == challenge.id }?
                .responses.first { $0.id == response.id }?.score != nil
        }
        
        if allScored {
            determineWinner()
        }
    }
    
    private func determineWinner() {
        // Find highest scored response
        var highestScore = 0
        var winnerId: String?
        
        for response in responses {
            if let score = dataManager.challenges.first(where: { $0.id == challenge.id })?
                .responses.first(where: { $0.id == response.id })?.score {
                if score > highestScore {
                    highestScore = score
                    winnerId = response.userId
                }
            }
        }
        
        guard let winnerId = winnerId else { return }
        
        // End the group match and create final match with winner
        dataManager.endMatch(match.id, winnerId: winnerId)
        
        // Show winner announcement
        showWinnerAnnouncement(winnerId: winnerId)
    }
    
    private func showWinnerAnnouncement(winnerId: String) {
        guard let winner = participants.first(where: { $0.id == winnerId }) else { return }
        
        let alert = UIAlertController(
            title: "🎉 We Have a Winner!",
            message: "\(winner.name) won the challenge! You're now matched.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Chatting", style: .default) { _ in
            // Navigate to chat with winner
            if let finalMatch = self.dataManager.getActiveMatches().last {
                let chatVC = ChatDetailViewController(match: finalMatch)
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Back to Matches", style: .cancel) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func createChallengeButtonTapped() {
        let alert = UIAlertController(title: "Create New Challenge", message: "What challenge would you like to give?", preferredStyle: .actionSheet)
        
        Challenge.ChallengeType.allCases.forEach { type in
            alert.addAction(UIAlertAction(title: type.displayName, style: .default) { _ in
                self.createNewChallenge(type: type)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func createNewChallenge(type: Challenge.ChallengeType) {
        let alert = UIAlertController(title: "New \(type.displayName)", message: nil, preferredStyle: .alert)
        
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
            
            // Create new challenge and reload
            _ = self.dataManager.createChallenge(title: title, description: description, type: type)
            
            // Refresh the view with new challenge
            self.challengeDescriptionLabel.text = description
            self.loadResponses()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}