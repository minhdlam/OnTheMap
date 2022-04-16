//
//  PostLocationController.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/12/22.
//

import UIKit
import CoreLocation

private let locationDetailsIdentifier = "LocationDetailsController"

class PostLocationController: UIViewController {
            
    // MARK: - IBOutlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.isHidden = true
        setupViews()
    }
    
    // MARK: - IBActions
    
    @IBAction func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleFindOnMap() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        geoCodeLocation { coordinate, error in
            if let error = error {
                self.showError(title: "Please enter a valid address.", message: error.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            
            self.activityIndicator.stopAnimating()
            let locationDetailsController = self.storyboard?.instantiateViewController(withIdentifier: locationDetailsIdentifier) as! LocationDetailsController
            locationDetailsController.studentCoordinate = coordinate
            locationDetailsController.mapString = self.locationTextField.text
            self.navigationController?.pushViewController(locationDetailsController, animated: true)
        }
    }
    
    // MARK: - Helper Methods
    
    func geoCodeLocation(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { placemarks, error in
            if error != nil {
                completion(nil, error)
                self.activityIndicator.isHidden = true
            }
            
            guard let placemarks = placemarks,
                  let placemark = placemarks.first,
                  let location = placemark.location else { return }
            
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            completion(coordinate, nil)
        }
    }
    
    func setupViews() {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        let attributedString = NSAttributedString(string: "Enter Your Location Here",
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        locationTextField.attributedPlaceholder = attributedString
    }
    
    func shouldHideIndicator() {
        
    }
}

