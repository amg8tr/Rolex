import UIKit

class SettingsViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let settingsSections = [
        ("Account", [
            ("Edit Profile", "person.circle"),
            ("Privacy Settings", "lock.shield"),
            ("Notifications", "bell")
        ]),
        ("App", [
            ("About", "info.circle"),
            ("Help & Support", "questionmark.circle"),
            ("Terms of Service", "doc.text"),
            ("Privacy Policy", "hand.raised")
        ]),
        ("Data", [
            ("Export Data", "square.and.arrow.up"),
            ("Clear All Data", "trash"),
            ("Log Out", "rectangle.portrait.and.arrow.right")
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }
    
    private func handleSettingTap(_ setting: String) {
        switch setting {
        case "Edit Profile":
            let editProfileVC = EditProfileViewController()
            navigationController?.pushViewController(editProfileVC, animated: true)
            
        case "Privacy Settings":
            showAlert(message: "Privacy settings coming soon!")
            
        case "Notifications":
            showAlert(message: "Notification settings coming soon!")
            
        case "About":
            showAlert(message: "Match Me v1.0\nA dating app that connects people through challenges and shared locations.")
            
        case "Help & Support":
            showAlert(message: "Help and support coming soon!")
            
        case "Terms of Service":
            showAlert(message: "Terms of service coming soon!")
            
        case "Privacy Policy":
            showAlert(message: "Privacy policy coming soon!")
            
        case "Export Data":
            showAlert(message: "Data export coming soon!")
            
        case "Clear All Data":
            showClearDataAlert()
            
        case "Log Out":
            showLogoutAlert()
            
        default:
            break
        }
    }
    
    private func showClearDataAlert() {
        let alert = UIAlertController(
            title: "Clear All Data",
            message: "This will permanently delete all your data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Clear Data", style: .destructive) { _ in
            // Clear all data
            self.dataManager.currentUser = nil
            self.dataManager.availableUsers.removeAll()
            self.dataManager.matches.removeAll()
            self.dataManager.challenges.removeAll()
            self.dataManager.chatMessages.removeAll()
            
            self.showAlert(message: "All data has been cleared.")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            // Clear current user
            self.dataManager.currentUser = nil
            self.dismiss(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsCell")
        
        let setting = settingsSections[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = setting.0
        cell.imageView?.image = UIImage(systemName: setting.1)
        cell.imageView?.tintColor = .systemPink
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsSections[section].0
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let setting = settingsSections[indexPath.section].1[indexPath.row].0
        handleSettingTap(setting)
    }
} 