import UIKit
import CoreLocation

class ProfileViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    
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
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemPink
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("My Locations", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(locationsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray6
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(editProfileButton)
        contentView.addSubview(locationsButton)
        contentView.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bioLabel.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 16),
            scoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            editProfileButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 30),
            editProfileButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editProfileButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editProfileButton.heightAnchor.constraint(equalToConstant: 50),
            
            locationsButton.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 16),
            locationsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            locationsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            locationsButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingsButton.topAnchor.constraint(equalTo: locationsButton.bottomAnchor, constant: 12),
            settingsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            settingsButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateProfile() {
        guard let currentUser = dataManager.currentUser else {
            // Show onboarding if no user exists
            showOnboarding()
            return
        }
        
        nameLabel.text = currentUser.name
        ageLabel.text = "\(currentUser.age) years old"
        bioLabel.text = currentUser.bio
        scoreLabel.text = "Score: \(String(format: "%.1f", currentUser.score)) • High scores: \(currentUser.highScoreCount)"
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        let navController = UINavigationController(rootViewController: onboardingVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func editProfileButtonTapped() {
        let editProfileVC = EditProfileViewController()
        let navController = UINavigationController(rootViewController: editProfileVC)
        present(navController, animated: true)
    }
    
    @objc private func locationsButtonTapped() {
        let locationsVC = LocationsViewController()
        navigationController?.pushViewController(locationsVC, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
} 