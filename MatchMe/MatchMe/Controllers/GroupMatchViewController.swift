import UIKit

class GroupMatchViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private var selectedUsers: [User] = []
    private var availableUsers: [User] = []
    private var currentSelectionIndex = 0
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select 3 Profiles to Compete"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose 3 people who will compete in challenges for a chance to match with you"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var selectedUsersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Group", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var startChallengeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Challenge", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startChallengeButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAvailableUsers()
        showCurrentUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Group Match"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(selectedUsersStackView)
        view.addSubview(cardContainerView)
        view.addSubview(selectButton)
        view.addSubview(skipButton)
        view.addSubview(startChallengeButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            selectedUsersStackView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            selectedUsersStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedUsersStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedUsersStackView.heightAnchor.constraint(equalToConstant: 100),
            
            cardContainerView.topAnchor.constraint(equalTo: selectedUsersStackView.bottomAnchor, constant: 20),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardContainerView.bottomAnchor.constraint(equalTo: selectButton.topAnchor, constant: -20),
            
            selectButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            selectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            selectButton.widthAnchor.constraint(equalToConstant: 150),
            selectButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            skipButton.widthAnchor.constraint(equalToConstant: 150),
            skipButton.heightAnchor.constraint(equalToConstant: 50),
            
            startChallengeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startChallengeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startChallengeButton.widthAnchor.constraint(equalToConstant: 200),
            startChallengeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Create placeholder views for selected users
        for _ in 0..<3 {
            let placeholderView = createSelectedUserPlaceholder()
            selectedUsersStackView.addArrangedSubview(placeholderView)
        }
    }
    
    private func createSelectedUserPlaceholder() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        let label = UILabel()
        label.text = "?"
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .systemGray3
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func createSelectedUserView(for user: User) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemPink.cgColor
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let ageLabel = UILabel()
        ageLabel.text = "\(user.age)"
        ageLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        ageLabel.textColor = .secondaryLabel
        ageLabel.textAlignment = .center
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(ageLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10),
            
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            ageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        return containerView
    }
    
    private func loadAvailableUsers() {
        availableUsers = dataManager.getUsersWithSharedLocations()
    }
    
    private func showCurrentUser() {
        guard currentSelectionIndex < availableUsers.count else {
            showNoMoreUsers()
            return
        }
        
        // Remove existing card
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let user = availableUsers[currentSelectionIndex]
        let userCard = UserCardView(user: user)
        userCard.translatesAutoresizingMaskIntoConstraints = false
        
        cardContainerView.addSubview(userCard)
        NSLayoutConstraint.activate([
            userCard.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            userCard.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            userCard.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            userCard.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        ])
    }
    
    private func showNoMoreUsers() {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = selectedUsers.count < 3 ? "No more profiles available.\nYou need \(3 - selectedUsers.count) more to start." : "Ready to start the challenge!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        cardContainerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -20)
        ])
        
        selectButton.isHidden = true
        skipButton.isHidden = true
        
        if selectedUsers.count == 3 {
            startChallengeButton.isHidden = false
        }
    }
    
    private func updateSelectedUsersDisplay() {
        // Clear existing views
        selectedUsersStackView.arrangedSubviews.forEach {
            selectedUsersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        // Add selected users
        for user in selectedUsers {
            let userView = createSelectedUserView(for: user)
            selectedUsersStackView.addArrangedSubview(userView)
        }
        
        // Add placeholders for remaining slots
        for _ in selectedUsers.count..<3 {
            let placeholderView = createSelectedUserPlaceholder()
            selectedUsersStackView.addArrangedSubview(placeholderView)
        }
        
        // Update instruction label
        if selectedUsers.count == 3 {
            instructionLabel.text = "Great! You've selected 3 profiles. Ready to start the challenge?"
            selectButton.isHidden = true
            skipButton.isHidden = true
            startChallengeButton.isHidden = false
        } else {
            instructionLabel.text = "You've selected \(selectedUsers.count) of 3 profiles"
        }
    }
    
    @objc private func selectButtonTapped() {
        guard currentSelectionIndex < availableUsers.count else { return }
        
        let user = availableUsers[currentSelectionIndex]
        
        if selectedUsers.count < 3 && !selectedUsers.contains(where: { $0.id == user.id }) {
            selectedUsers.append(user)
            updateSelectedUsersDisplay()
        }
        
        currentSelectionIndex += 1
        
        if selectedUsers.count == 3 {
            showNoMoreUsers()
        } else {
            showCurrentUser()
        }
    }
    
    @objc private func skipButtonTapped() {
        currentSelectionIndex += 1
        showCurrentUser()
    }
    
    @objc private func startChallengeButtonTapped() {
        guard selectedUsers.count == 3 else { return }
        
        // Create a group challenge
        let challenge = dataManager.createChallenge(
            title: "Group Challenge",
            description: "Compete to win a match! Show your best self.",
            type: .hypothetical
        )
        
        // Create group match
        let match = dataManager.createGroupMatch(selectedUsers: selectedUsers, challengeId: challenge.id)
        
        // Navigate to group challenge view
        let groupChallengeVC = GroupChallengeViewController(match: match, challenge: challenge)
        navigationController?.pushViewController(groupChallengeVC, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}