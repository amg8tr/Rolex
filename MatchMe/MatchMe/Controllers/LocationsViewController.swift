import UIKit
import CoreLocation

class LocationsViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private var visitedLocations: [Location] = []
    private var savedLocations: [Location] = []
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Visited", "Saved"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Current Location", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addLocationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLocations()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My Locations"
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(addLocationButton)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addLocationButton.topAnchor, constant: -16),
            
            addLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addLocationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addLocationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func loadLocations() {
        guard let currentUser = dataManager.currentUser else { return }
        
        visitedLocations = currentUser.visitedLocations
        savedLocations = currentUser.savedLocations
        
        tableView.reloadData()
    }
    
    @objc private func segmentChanged() {
        tableView.reloadData()
    }
    
    @objc private func addLocationButtonTapped() {
        guard let currentLocation = dataManager.userLocation else {
            showAlert(message: "Unable to get current location")
            return
        }
        
        let alert = UIAlertController(title: "Add Location", message: "Enter a name for this location", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Location name"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty else {
                return
            }
            
            let location = Location(
                name: name,
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
            
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.dataManager.addVisitedLocation(location)
            } else {
                self.dataManager.addSavedLocation(location)
            }
            
            self.loadLocations()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LocationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? visitedLocations.count : savedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationTableViewCell
        
        let locations = segmentedControl.selectedSegmentIndex == 0 ? visitedLocations : savedLocations
        let location = locations[indexPath.row]
        cell.configure(with: location)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let locations = segmentedControl.selectedSegmentIndex == 0 ? visitedLocations : savedLocations
            let location = locations[indexPath.row]
            
            // Remove location from user
            if var currentUser = dataManager.currentUser {
                if segmentedControl.selectedSegmentIndex == 0 {
                    currentUser.visitedLocations.removeAll { $0.id == location.id }
                } else {
                    currentUser.savedLocations.removeAll { $0.id == location.id }
                }
                dataManager.updateUserProfile(currentUser)
            }
            
            loadLocations()
        }
    }
} 