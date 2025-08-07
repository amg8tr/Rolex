import UIKit

class ChatMessageCell: UITableViewCell {
    
    private lazy var messageBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        
        contentView.addSubview(messageBubbleView)
        messageBubbleView.addSubview(messageLabel)
        messageBubbleView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            messageBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            messageBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            messageBubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7),
            
            messageLabel.topAnchor.constraint(equalTo: messageBubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: messageBubbleView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: ChatMessage, isFromCurrentUser: Bool) {
        messageLabel.text = message.message
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        if isFromCurrentUser {
            // Current user's message (right side)
            messageBubbleView.backgroundColor = .systemPink
            messageLabel.textColor = .white
            timeLabel.textColor = .white.withAlphaComponent(0.8)
            
            NSLayoutConstraint.deactivate(leftConstraints)
            NSLayoutConstraint.activate(rightConstraints)
        } else {
            // Other user's message (left side)
            messageBubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .label
            timeLabel.textColor = .tertiaryLabel
            
            NSLayoutConstraint.deactivate(rightConstraints)
            NSLayoutConstraint.activate(leftConstraints)
        }
    }
    
    private lazy var leftConstraints: [NSLayoutConstraint] = [
        messageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
    ]
    
    private lazy var rightConstraints: [NSLayoutConstraint] = [
        messageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ]
} 