import UIKit

protocol MatchTableViewCellDelegate: AnyObject {
    func matchTableViewCell(_ cell: MatchTableViewCell, didTapChallengeButton match: Match)
}

class MatchTableViewCell: UITableViewCell {
    
    weak var delegate: MatchTableViewCellDelegate?
    private var match: Match?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGreen
        label.text = "Active Match"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var challengeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Challenge", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(challengeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(challengeButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: challengeButton.leadingAnchor, constant: -12),
            
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: challengeButton.leadingAnchor, constant: -12),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),
            
            challengeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            challengeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            challengeButton.widthAnchor.constraint(equalToConstant: 80),
            challengeButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with match: Match, userNames: String) {
        self.match = match
        nameLabel.text = userNames
        
        // Update UI based on match type
        if match.participants.count > 2 {
            statusLabel.text = "Group Challenge"
            statusLabel.textColor = .systemPurple
            challengeButton.setTitle("View", for: .normal)
            challengeButton.backgroundColor = .systemPurple
            avatarImageView.image = UIImage(systemName: "person.3.fill")
        } else {
            statusLabel.text = match.isActive ? "Active Match" : "Completed"
            statusLabel.textColor = match.isActive ? .systemGreen : .systemGray
            challengeButton.setTitle("Challenge", for: .normal)
            challengeButton.backgroundColor = .systemPink
            avatarImageView.image = UIImage(systemName: "person.2.fill")
        }
    }
    
    @objc private func challengeButtonTapped() {
        guard let match = match else { return }
        delegate?.matchTableViewCell(self, didTapChallengeButton: match)
    }
} 