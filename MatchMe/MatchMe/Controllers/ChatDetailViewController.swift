import UIKit
import AVFoundation

class ChatDetailViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let match: Match
    private var messages: [ChatMessage] = []
    private var isOtherUserTyping = false
    private var typingTimer: Timer?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .systemPink
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .systemPink
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(mediaButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var typingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 15
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Typing..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let dotsView = createTypingDotsView()
        dotsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(dotsView)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            dotsView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            dotsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dotsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            dotsView.widthAnchor.constraint(equalToConstant: 30),
            dotsView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        return view
    }()
    
    private func createTypingDotsView() -> UIView {
        let containerView = UIView()
        let dots = [UIView(), UIView(), UIView()]
        
        for (index, dot) in dots.enumerated() {
            dot.backgroundColor = .systemGray
            dot.layer.cornerRadius = 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4),
                dot.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                dot.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CGFloat(index * 10))
            ])
            
            // Animate dots
            UIView.animate(withDuration: 0.6, delay: Double(index) * 0.2, options: [.repeat, .autoreverse], animations: {
                dot.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                dot.alpha = 0.5
            })
        }
        
        return containerView
    }
    
    init(match: Match) {
        self.match = match
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
        setupKeyboardObservers()
        setupTextFieldDelegate()
        simulateTypingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        typingTimer?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Chat"
        
        view.addSubview(tableView)
        view.addSubview(typingIndicatorView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(mediaButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            typingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typingIndicatorView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -8),
            typingIndicatorView.widthAnchor.constraint(equalToConstant: 100),
            typingIndicatorView.heightAnchor.constraint(equalToConstant: 30),
            
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            messageTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 12),
            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            messageTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -12),
            
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: mediaButton.leadingAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            mediaButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            mediaButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            mediaButton.widthAnchor.constraint(equalToConstant: 44),
            mediaButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func loadMessages() {
        messages = dataManager.getMessages(for: match.id)
        tableView.reloadData()
        
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc private func sendButtonTapped() {
        guard let messageText = messageTextField.text, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let message = dataManager.sendMessage(to: match.id, message: messageText)
        messages.append(message)
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        messageTextField.text = ""
    }
    
    @objc private func mediaButtonTapped() {
        let mediaCaptureVC = MediaCaptureViewController()
        mediaCaptureVC.delegate = self
        mediaCaptureVC.modalPresentationStyle = .fullScreen
        present(mediaCaptureVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        let isFromCurrentUser = message.senderId == dataManager.currentUser?.id
        cell.configure(with: message, isFromCurrentUser: isFromCurrentUser)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextFieldDelegate

extension ChatDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Simulate other user stopping typing when current user starts
        hideTypingIndicator()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonTapped()
        return true
    }
}

// MARK: - MediaCaptureViewControllerDelegate

extension ChatDetailViewController: MediaCaptureViewControllerDelegate {
    func mediaCaptureViewController(_ controller: MediaCaptureViewController, didCaptureMedia url: URL, type: ChatMessage.MessageType) {
        controller.dismiss(animated: true) {
            // Send media message
            let messageText: String
            switch type {
            case .photo:
                messageText = "📷 Photo shared"
            case .video:
                messageText = "🎥 Video shared"
            case .audio:
                messageText = "🎤 Audio message"
            default:
                messageText = "Media shared"
            }
            
            let message = self.dataManager.sendMessage(
                to: self.match.id,
                message: messageText,
                messageType: type,
                mediaURL: url.absoluteString
            )
            
            self.messages.append(message)
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func mediaCaptureViewControllerDidCancel(_ controller: MediaCaptureViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Helper Methods

extension ChatDetailViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupTextFieldDelegate() {
        messageTextField.delegate = self
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        // Scroll to bottom
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
    
    private func simulateTypingIndicator() {
        // Simulate other user typing after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showTypingIndicator()
            
            // Hide after a few seconds and add a message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideTypingIndicator()
                self.simulateReceivedMessage()
            }
        }
    }
    
    private func showTypingIndicator() {
        isOtherUserTyping = true
        typingIndicatorView.isHidden = false
        typingIndicatorView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.typingIndicatorView.alpha = 1
        }
    }
    
    private func hideTypingIndicator() {
        UIView.animate(withDuration: 0.3, animations: {
            self.typingIndicatorView.alpha = 0
        }) { _ in
            self.typingIndicatorView.isHidden = true
            self.isOtherUserTyping = false
        }
    }
    
    private func simulateReceivedMessage() {
        let responses = [
            "That sounds great! 😊",
            "I totally agree with you!",
            "When should we meet up?",
            "Your profile is amazing btw!",
            "Haha that's so funny!",
            "I was thinking the same thing!"
        ]
        
        if let randomResponse = responses.randomElement() {
            _ = dataManager.sendMessage(
                to: match.id,
                message: randomResponse,
                messageType: .text,
                mediaURL: nil
            )
            loadMessages()
        }
    }
} 