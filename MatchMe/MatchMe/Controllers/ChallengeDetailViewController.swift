import UIKit

class ChallengeDetailViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let challenge: Challenge
    private let match: Match
    
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemPink
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var responseTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.text = "Write your response..."
        textView.textColor = .placeholderText
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Response", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var responsesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChallengeResponseCell.self, forCellReuseIdentifier: "ResponseCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(challenge: Challenge, match: Match) {
        self.challenge = challenge
        self.match = match
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextViewDelegate()
        configureWithChallenge()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Challenge"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(responseTextView)
        contentView.addSubview(submitButton)
        contentView.addSubview(responsesTableView)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            responseTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            responseTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responseTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            responseTextView.heightAnchor.constraint(equalToConstant: 100),
            
            submitButton.topAnchor.constraint(equalTo: responseTextView.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            responsesTableView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            responsesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            responsesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            responsesTableView.heightAnchor.constraint(equalToConstant: 200),
            responsesTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTextViewDelegate() {
        responseTextView.delegate = self
    }
    
    private func configureWithChallenge() {
        titleLabel.text = challenge.title
        typeLabel.text = challenge.type.displayName
        descriptionLabel.text = challenge.description
    }
    
    @objc private func submitButtonTapped() {
        guard let responseText = responseTextView.text, !responseText.isEmpty, responseText != "Write your response..." else {
            showAlert(message: "Please write a response")
            return
        }
        
        let response = dataManager.addResponse(to: challenge.id, response: responseText)
        
        // Clear the text view
        responseTextView.text = ""
        
        // Reload responses
        responsesTableView.reloadData()
        
        showAlert(message: "Response submitted successfully!")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChallengeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenge.responses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResponseCell", for: indexPath) as! ChallengeResponseCell
        let response = challenge.responses[indexPath.row]
        cell.configure(with: response)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChallengeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextViewDelegate

extension ChallengeDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your response..."
            textView.textColor = .placeholderText
        }
    }
} 