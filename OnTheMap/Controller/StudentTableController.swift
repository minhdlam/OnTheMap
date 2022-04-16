//
//  UserTableController.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/12/22.
//

import UIKit

private let reuseIdentifier = "StudentCell"
private let postLocationIdentifier = "postLocationFromTableTab"

class StudentTableController: UITableViewController {
    
    // MARK: - Properties
    
    var studentLocations: [StudentLocationResponse] {
        return StudentLocations.studentLocations
    }
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        UdacityClient.getStudentLocations(completion: handleStudentLocationsResponse(studentLocations:error:))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! StudentCell
        let studentLocation = studentLocations[indexPath.row]
        let firstName = studentLocation.firstName
        let lastName = studentLocation.lastName
        cell.nameLabel.text = "\(firstName) \(lastName)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentLocations[indexPath.row]
        guard let mediaURL = URL(string: studentLocation.mediaURL) else { return }
        
        UIApplication.shared.open(mediaURL)
    }
    
    // MARK: - IBActions
    
    @IBAction func handleLogout() {
        UdacityClient.logout(completion: handleLogoutResponse(success:error:))
    }
    
    @IBAction func handlePostLocation() {
        let postLocationController = storyboard?.instantiateViewController(withIdentifier: postLocationIdentifier) as! PostLocationController
        navigationController?.pushViewController(postLocationController, animated: true)
    }
    
    // MARK: - Helper Methods
    
    func handleStudentLocationsResponse(studentLocations: [StudentLocationResponse], error: Error?) -> Void {
        if let error = error {
            showError(title: "Unable to load student locations at this time, please try again.", message: error.localizedDescription)
        } else {
            StudentLocations.studentLocations = studentLocations
            tableView.reloadData()
        }
    }
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        if success {
            dismiss(animated: true)
        } else {
            guard let error = error else { return }
            showError(title: "Had trouble logging out student.", message: error.localizedDescription)
        }
    }
        
    func setupViews() {
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
}
