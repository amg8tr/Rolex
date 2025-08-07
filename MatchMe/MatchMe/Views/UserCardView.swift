import UIKit

protocol UserCardViewDelegate: AnyObject {
    func userCardView(_ cardView: UserCardView, didLike user: User)
    func userCardView(_ cardView: UserCardView, didDislike user: User)
    func userCardView(_ cardView: UserCardView, didSuperLike user: User)
}

class UserCardView: UIView {
    
    weak var delegate: UserCardViewDelegate?
    private let user: User
    
    // Swipe gesture properties
    private var originalCenter: CGPoint = .zero
    private var panGesture: UIPanGestureRecognizer!
    private let swipeThreshold: CGFloat = 100
    private let rotationAngle: CGFloat = 0.61 // 35 degrees
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var highScoreBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .white
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(starIcon)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            starIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            starIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 12),
            starIcon.heightAnchor.constraint(equalToConstant: 12),
            
            label.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 4),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6)
        ])
        
        view.tag = 999 // Tag to identify label later
        label.tag = 1000 // Tag to update text
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemPink.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .systemPink
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(starIcon)
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            starIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            starIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 16),
            starIcon.heightAnchor.constraint(equalToConstant: 16),
            
            scoreLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 4),
            scoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .systemGreen
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dislikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemRed
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var superLikeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(superLikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "LIKE"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var nopeOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "NOPE"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private lazy var superLikeOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        view.layer.cornerRadius = 8
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "SUPER\nLIKE"
        label.textColor = .white
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        setupUI()
        configureWithUser()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(cardView)
        cardView.addSubview(profileImageView)
        cardView.addSubview(highScoreBadge)
        cardView.addSubview(scoreContainerView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(ageLabel)
        cardView.addSubview(bioLabel)
        cardView.addSubview(likeOverlay)
        cardView.addSubview(nopeOverlay)
        cardView.addSubview(superLikeOverlay)
        addSubview(likeButton)
        addSubview(dislikeButton)
        addSubview(superLikeButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),
            
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1.2),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            ageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            bioLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bioLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            scoreContainerView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 12),
            scoreContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            scoreContainerView.heightAnchor.constraint(equalToConstant: 30),
            scoreContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            scoreContainerView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
            
            highScoreBadge.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 10),
            highScoreBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -10),
            highScoreBadge.heightAnchor.constraint(equalToConstant: 24),
            highScoreBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            likeButton.centerYAnchor.constraint(equalTo: dislikeButton.centerYAnchor),
            likeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
            
            dislikeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dislikeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            dislikeButton.widthAnchor.constraint(equalToConstant: 50),
            dislikeButton.heightAnchor.constraint(equalToConstant: 50),
            
            superLikeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            superLikeButton.centerYAnchor.constraint(equalTo: dislikeButton.centerYAnchor),
            superLikeButton.widthAnchor.constraint(equalToConstant: 50),
            superLikeButton.heightAnchor.constraint(equalToConstant: 50),
            
            likeOverlay.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 50),
            likeOverlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            likeOverlay.widthAnchor.constraint(equalToConstant: 100),
            likeOverlay.heightAnchor.constraint(equalToConstant: 50),
            
            nopeOverlay.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 50),
            nopeOverlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            nopeOverlay.widthAnchor.constraint(equalToConstant: 100),
            nopeOverlay.heightAnchor.constraint(equalToConstant: 50),
            
            superLikeOverlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -50),
            superLikeOverlay.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            superLikeOverlay.widthAnchor.constraint(equalToConstant: 100),
            superLikeOverlay.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func configureWithUser() {
        nameLabel.text = user.name
        ageLabel.text = "\(user.age) years old"
        bioLabel.text = user.bio
        
        // Configure score display
        let scoreText = String(format: "%.1f", user.score)
        scoreLabel.text = scoreText
        
        // Show high score badge if user has many high scores
        if user.highScoreCount >= 5 {
            highScoreBadge.isHidden = false
            if let label = highScoreBadge.viewWithTag(1000) as? UILabel {
                label.text = "\(user.highScoreCount)"
            }
        } else {
            highScoreBadge.isHidden = true
        }
        
        // Set profile image
        if let imageURL = user.profileImageURL {
            // In a real app, you would load the image from the URL
            // For now, we'll use different system images based on gender
            switch user.gender {
            case .female:
                profileImageView.image = UIImage(systemName: "person.fill")
                profileImageView.tintColor = .systemPink
            case .male:
                profileImageView.image = UIImage(systemName: "person.fill")
                profileImageView.tintColor = .systemBlue
            case .other:
                profileImageView.image = UIImage(systemName: "person.fill")
                profileImageView.tintColor = .systemPurple
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemGray3
        }
    }
    
    @objc private func likeButtonTapped() {
        animateButton(likeButton) {
            self.delegate?.userCardView(self, didLike: self.user)
        }
    }
    
    @objc private func dislikeButtonTapped() {
        animateButton(dislikeButton) {
            self.delegate?.userCardView(self, didDislike: self.user)
        }
    }
    
    private func animateButton(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }
    
    @objc private func superLikeButtonTapped() {
        animateButton(superLikeButton) {
            self.animateSwipe(direction: .up) {
                self.delegate?.userCardView(self, didSuperLike: self.user)
            }
        }
    }
    
    // MARK: - Swipe Gestures
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        cardView.addGestureRecognizer(panGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            originalCenter = cardView.center
            
        case .changed:
            // Move the card
            cardView.center = CGPoint(x: originalCenter.x + translation.x,
                                    y: originalCenter.y + translation.y)
            
            // Rotate the card
            let rotationStrength = min(translation.x / 320, 1)
            let rotation = rotationAngle * rotationStrength
            cardView.transform = CGAffineTransform(rotationAngle: rotation)
            
            // Update overlay alphas
            let horizontalDistance = translation.x
            let verticalDistance = translation.y
            
            if horizontalDistance > 0 {
                likeOverlay.alpha = min(horizontalDistance / swipeThreshold, 1)
                nopeOverlay.alpha = 0
                superLikeOverlay.alpha = 0
            } else if horizontalDistance < 0 {
                nopeOverlay.alpha = min(abs(horizontalDistance) / swipeThreshold, 1)
                likeOverlay.alpha = 0
                superLikeOverlay.alpha = 0
            }
            
            if verticalDistance < -50 {
                superLikeOverlay.alpha = min(abs(verticalDistance) / swipeThreshold, 1)
                likeOverlay.alpha = 0
                nopeOverlay.alpha = 0
            }
            
        case .ended:
            // Determine if we should complete the swipe
            if translation.x > swipeThreshold {
                // Like
                animateSwipe(direction: .right) {
                    self.delegate?.userCardView(self, didLike: self.user)
                }
            } else if translation.x < -swipeThreshold {
                // Dislike
                animateSwipe(direction: .left) {
                    self.delegate?.userCardView(self, didDislike: self.user)
                }
            } else if translation.y < -swipeThreshold && abs(velocity.y) > 500 {
                // Super Like (swipe up with velocity)
                animateSwipe(direction: .up) {
                    self.delegate?.userCardView(self, didSuperLike: self.user)
                }
            } else {
                // Return to center
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
                    self.cardView.center = self.originalCenter
                    self.cardView.transform = .identity
                    self.likeOverlay.alpha = 0
                    self.nopeOverlay.alpha = 0
                    self.superLikeOverlay.alpha = 0
                }
            }
            
        default:
            break
        }
    }
    
    private enum SwipeDirection {
        case left, right, up
    }
    
    private func animateSwipe(direction: SwipeDirection, completion: @escaping () -> Void) {
        let translationX: CGFloat
        let translationY: CGFloat
        let rotation: CGFloat
        
        switch direction {
        case .left:
            translationX = -UIScreen.main.bounds.width - 100
            translationY = 0
            rotation = -rotationAngle
        case .right:
            translationX = UIScreen.main.bounds.width + 100
            translationY = 0
            rotation = rotationAngle
        case .up:
            translationX = 0
            translationY = -UIScreen.main.bounds.height - 100
            rotation = 0
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.cardView.center = CGPoint(x: self.originalCenter.x + translationX,
                                         y: self.originalCenter.y + translationY)
            self.cardView.transform = CGAffineTransform(rotationAngle: rotation)
            self.alpha = 0
        }) { _ in
            completion()
        }
    }
} 