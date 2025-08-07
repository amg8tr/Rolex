import UIKit

protocol DateScoreViewControllerDelegate: AnyObject {
    func dateScoreViewController(_ controller: DateScoreViewController, didScore score: Int, comment: String?)
}

class DateScoreViewController: UIViewController {
    
    weak var delegate: DateScoreViewControllerDelegate?
    private let dataManager = DataManager.shared
    private let match: Match
    private let otherUser: User
    private var selectedScore: Int = 5
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "How was your date?"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate your experience with \(otherUser.name)"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemPink
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "\(otherUser.name), \(otherUser.age)"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .systemPink
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scoreSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = 5
        slider.tintColor = .systemPink
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var scoreDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = getScoreDescription(for: 5)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemPink
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.backgroundColor = .systemGray6
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Add a comment (optional)..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Rating", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip for Now", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...10 {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: i <= 5 ? "star.fill" : "star"), for: .normal)
            button.tintColor = i <= 5 ? .systemYellow : .systemGray4
            button.tag = i
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }()
    
    init(match: Match, otherUser: User) {
        self.match = match
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Rate Your Date"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        commentTextView.addSubview(placeholderLabel)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(userImageView)
        view.addSubview(userNameLabel)
        view.addSubview(scoreLabel)
        view.addSubview(scoreSlider)
        view.addSubview(scoreDescriptionLabel)
        view.addSubview(starStackView)
        view.addSubview(commentTextView)
        view.addSubview(submitButton)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            userImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 120),
            userImageView.heightAnchor.constraint(equalToConstant: 120),
            
            userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 15),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 30),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreSlider.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            scoreSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            scoreSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            scoreDescriptionLabel.topAnchor.constraint(equalTo: scoreSlider.bottomAnchor, constant: 10),
            scoreDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            starStackView.topAnchor.constraint(equalTo: scoreDescriptionLabel.bottomAnchor, constant: 20),
            starStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            starStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            starStackView.heightAnchor.constraint(equalToConstant: 30),
            
            commentTextView.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 30),
            commentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 100),
            
            placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 16),
            
            submitButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 30),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 15),
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        commentTextView.delegate = self
    }
    
    private func getScoreDescription(for score: Int) -> String {
        switch score {
        case 1...2:
            return "😔 Not a good match"
        case 3...4:
            return "😐 It was okay"
        case 5...6:
            return "🙂 Pretty good"
        case 7...8:
            return "😊 Great time!"
        case 9...10:
            return "🤩 Amazing! Perfect match!"
        default:
            return ""
        }
    }
    
    private func updateStars(for score: Int) {
        for case let button as UIButton in starStackView.arrangedSubviews {
            let shouldFill = button.tag <= score
            button.setImage(UIImage(systemName: shouldFill ? "star.fill" : "star"), for: .normal)
            button.tintColor = shouldFill ? .systemYellow : .systemGray4
        }
    }
    
    @objc private func sliderValueChanged() {
        selectedScore = Int(scoreSlider.value.rounded())
        scoreLabel.text = "\(selectedScore)"
        scoreDescriptionLabel.text = getScoreDescription(for: selectedScore)
        updateStars(for: selectedScore)
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        selectedScore = sender.tag
        scoreSlider.value = Float(selectedScore)
        scoreLabel.text = "\(selectedScore)"
        scoreDescriptionLabel.text = getScoreDescription(for: selectedScore)
        updateStars(for: selectedScore)
    }
    
    @objc private func submitButtonTapped() {
        let comment = commentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalComment = (comment?.isEmpty ?? true) ? nil : comment
        
        // Score the date
        dataManager.scoreDate(
            fromUserId: dataManager.currentUser?.id ?? "",
            toUserId: otherUser.id,
            score: selectedScore,
            comment: finalComment
        )
        
        // Notify delegate
        delegate?.dateScoreViewController(self, didScore: selectedScore, comment: finalComment)
        
        // Show confirmation
        showConfirmation()
    }
    
    @objc private func skipButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func showConfirmation() {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Your rating has been submitted. We hope you had a great time!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
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
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -keyboardSize.height / 3
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - UITextViewDelegate

extension DateScoreViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}