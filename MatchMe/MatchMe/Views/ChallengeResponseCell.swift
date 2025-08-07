import UIKit

class ChallengeResponseCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        containerView.addSubview(responseLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            responseLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            responseLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            responseLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: responseLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            scoreLabel.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with response: ChallengeResponse) {
        responseLabel.text = response.response
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        timeLabel.text = formatter.string(from: response.respondedAt)
        
        if let score = response.score {
            scoreLabel.text = "Score: \(score)/10"
            scoreLabel.isHidden = false
        } else {
            scoreLabel.isHidden = true
        }
    }
} 