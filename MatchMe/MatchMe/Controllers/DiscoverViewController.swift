import UIKit
import SwiftUI

class DiscoverViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private var currentUserIndex = 0
    private var filteredUsers: [User] = []
    
    private lazy var cardStackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .systemPink
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var groupMatchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Group Match", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(groupMatchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noMoreUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "No more users to discover!\nCheck back later."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUsers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Discover"
        
        view.addSubview(cardStackView)
        view.addSubview(filterButton)
        view.addSubview(groupMatchButton)
        view.addSubview(noMoreUsersLabel)
        
        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            groupMatchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            groupMatchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            groupMatchButton.widthAnchor.constraint(equalToConstant: 120),
            groupMatchButton.heightAnchor.constraint(equalToConstant: 40),
            
            noMoreUsersLabel.centerXAnchor.constraint(equalTo: cardStackView.centerXAnchor),
            noMoreUsersLabel.centerYAnchor.constraint(equalTo: cardStackView.centerYAnchor),
            noMoreUsersLabel.leadingAnchor.constraint(equalTo: cardStackView.leadingAnchor, constant: 20),
            noMoreUsersLabel.trailingAnchor.constraint(equalTo: cardStackView.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadUsers() {
        filteredUsers = dataManager.getUsersWithSharedLocations()
        currentUserIndex = 0
        
        if filteredUsers.isEmpty {
            showNoMoreUsers()
        } else {
            showCurrentUser()
        }
    }
    
    private func showCurrentUser() {
        guard currentUserIndex < filteredUsers.count else {
            showNoMoreUsers()
            return
        }
        
        let user = filteredUsers[currentUserIndex]
        let userCard = UserCardView(user: user)
        userCard.delegate = self
        userCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing cards
        cardStackView.subviews.forEach { $0.removeFromSuperview() }
        
        cardStackView.addSubview(userCard)
        NSLayoutConstraint.activate([
            userCard.topAnchor.constraint(equalTo: cardStackView.topAnchor),
            userCard.leadingAnchor.constraint(equalTo: cardStackView.leadingAnchor),
            userCard.trailingAnchor.constraint(equalTo: cardStackView.trailingAnchor),
            userCard.bottomAnchor.constraint(equalTo: cardStackView.bottomAnchor)
        ])
        
        noMoreUsersLabel.isHidden = true
    }
    
    private func showNoMoreUsers() {
        cardStackView.subviews.forEach { $0.removeFromSuperview() }
        noMoreUsersLabel.isHidden = false
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
    
    @objc private func groupMatchButtonTapped() {
        let groupMatchVC = GroupMatchViewController()
        let navController = UINavigationController(rootViewController: groupMatchVC)
        present(navController, animated: true)
    }
}

// MARK: - UserCardViewDelegate

extension DiscoverViewController: UserCardViewDelegate {
    func userCardView(_ cardView: UserCardView, didSuperLike user: User) {
        // Create a special challenge for super like
        let challenge = dataManager.createChallenge(
            title: "⭐ Super Match Challenge!",
            description: "You super liked each other! Share something special.",
            type: .hypothetical
        )
        
        let match = dataManager.createMatch(
            participants: [dataManager.currentUser?.id ?? "", user.id],
            challengeId: challenge.id
        )
        
        // Show special match animation for super like
        showSuperMatchAnimation(with: user)
        
        // Move to next user
        currentUserIndex += 1
        showCurrentUser()
    }
    
    func userCardView(_ cardView: UserCardView, didLike user: User) {
        // Create a challenge and match
        let challenge = dataManager.createChallenge(
            title: "Get to know each other!",
            description: "Let's see how well we connect!",
            type: .question
        )
        
        let match = dataManager.createMatch(
            participants: [dataManager.currentUser?.id ?? "", user.id],
            challengeId: challenge.id
        )
        
        // Show match success
        showMatchSuccess(with: user)
        
        // Move to next user
        currentUserIndex += 1
        showCurrentUser()
    }
    
    func userCardView(_ cardView: UserCardView, didDislike user: User) {
        // Move to next user
        currentUserIndex += 1
        showCurrentUser()
    }
    
    private func showMatchSuccess(with user: User) {
        // Create match animation view
        let matchView = createMatchAnimationView(with: user, isSuperLike: false)
        view.addSubview(matchView)
        
        NSLayoutConstraint.activate([
            matchView.topAnchor.constraint(equalTo: view.topAnchor),
            matchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            matchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            matchView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animate the match view
        matchView.alpha = 0
        matchView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3, animations: {
            matchView.alpha = 1
            matchView.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    matchView.alpha = 0
                }) { _ in
                    matchView.removeFromSuperview()
                }
            }
        }
    }
    
    private func showSuperMatchAnimation(with user: User) {
        // Create super match animation view
        let matchView = createMatchAnimationView(with: user, isSuperLike: true)
        view.addSubview(matchView)
        
        NSLayoutConstraint.activate([
            matchView.topAnchor.constraint(equalTo: view.topAnchor),
            matchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            matchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            matchView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Animate with extra effects for super like
        matchView.alpha = 0
        matchView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            matchView.alpha = 1
            matchView.transform = .identity
        }) { _ in
            // Add particle effect
            self.addParticleEffect(to: matchView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    matchView.alpha = 0
                }) { _ in
                    matchView.removeFromSuperview()
                }
            }
        }
    }
    
    private func createMatchAnimationView(with user: User, isSuperLike: Bool) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let matchLabel = UILabel()
        matchLabel.text = isSuperLike ? "⭐ SUPER MATCH! ⭐" : "IT'S A MATCH!"
        matchLabel.textColor = isSuperLike ? .systemYellow : .white
        matchLabel.font = UIFont.systemFont(ofSize: isSuperLike ? 36 : 32, weight: .bold)
        matchLabel.textAlignment = .center
        matchLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = "You and \(user.name) liked each other!"
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Keep Swiping", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemPink
        continueButton.layer.cornerRadius = 25
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let chatButton = UIButton(type: .system)
        chatButton.setTitle("Send Message", for: .normal)
        chatButton.setTitleColor(.systemPink, for: .normal)
        chatButton.backgroundColor = .white
        chatButton.layer.cornerRadius = 25
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(matchLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(continueButton)
        containerView.addSubview(chatButton)
        
        NSLayoutConstraint.activate([
            matchLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            matchLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -100),
            
            messageLabel.topAnchor.constraint(equalTo: matchLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            
            chatButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 40),
            chatButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            chatButton.widthAnchor.constraint(equalToConstant: 200),
            chatButton.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.topAnchor.constraint(equalTo: chatButton.bottomAnchor, constant: 15),
            continueButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return containerView
    }
    
    private func addParticleEffect(to view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 100, height: 100)
        
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 2.0
        cell.velocity = 150
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.spin = 2
        cell.spinRange = 3
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.contents = createStarImage().cgImage
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            emitter.birthRate = 0
        }
    }
    
    private func createStarImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.systemYellow.setFill()
        
        let path = UIBezierPath()
        let center = CGPoint(x: 10, y: 10)
        let radius: CGFloat = 8
        
        for i in 0..<5 {
            let angle = (.pi * 2 / 5) * CGFloat(i) - .pi / 2
            let point = CGPoint(x: center.x + radius * cos(angle),
                              y: center.y + radius * sin(angle))
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: center.x + radius * 0.4 * cos(innerAngle),
                                   y: center.y + radius * 0.4 * sin(innerAngle))
            path.addLine(to: innerPoint)
        }
        
        path.close()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

// MARK: - FilterViewControllerDelegate

extension DiscoverViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didApplyFilters gender: User.Gender?, minAge: Int?, maxAge: Int?) {
        filteredUsers = dataManager.filterUsers(by: gender, minAge: minAge, maxAge: maxAge)
        currentUserIndex = 0
        showCurrentUser()
    }
} 