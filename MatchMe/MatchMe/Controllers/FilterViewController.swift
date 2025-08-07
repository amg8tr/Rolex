import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didApplyFilters gender: User.Gender?, minAge: Int?, maxAge: Int?)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var selectedGender: User.Gender?
    private var minAge: Int?
    private var maxAge: Int?
    
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
    
    private lazy var genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var genderSegmentedControl: UISegmentedControl = {
        let items = ["Any", "Male", "Female", "Other"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(genderChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var ageRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Age Range"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var minAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "Minimum Age"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var minAgeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "18"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var maxAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "Maximum Age"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var maxAgeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "50"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filters", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Filters"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegmentedControl)
        contentView.addSubview(ageRangeLabel)
        contentView.addSubview(minAgeLabel)
        contentView.addSubview(minAgeTextField)
        contentView.addSubview(maxAgeLabel)
        contentView.addSubview(maxAgeTextField)
        contentView.addSubview(applyButton)
        
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
            
            genderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 12),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ageRangeLabel.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 30),
            ageRangeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ageRangeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            minAgeLabel.topAnchor.constraint(equalTo: ageRangeLabel.bottomAnchor, constant: 12),
            minAgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            minAgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            minAgeTextField.topAnchor.constraint(equalTo: minAgeLabel.bottomAnchor, constant: 8),
            minAgeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            minAgeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            minAgeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            maxAgeLabel.topAnchor.constraint(equalTo: minAgeTextField.bottomAnchor, constant: 16),
            maxAgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            maxAgeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            maxAgeTextField.topAnchor.constraint(equalTo: maxAgeLabel.bottomAnchor, constant: 8),
            maxAgeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            maxAgeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            maxAgeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            applyButton.topAnchor.constraint(equalTo: maxAgeTextField.bottomAnchor, constant: 40),
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func genderChanged() {
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedGender = nil
        case 1:
            selectedGender = .male
        case 2:
            selectedGender = .female
        case 3:
            selectedGender = .other
        default:
            selectedGender = nil
        }
    }
    
    @objc private func applyButtonTapped() {
        // Parse age inputs
        minAge = Int(minAgeTextField.text ?? "")
        maxAge = Int(maxAgeTextField.text ?? "")
        
        delegate?.filterViewController(self, didApplyFilters: selectedGender, minAge: minAge, maxAge: maxAge)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
} 