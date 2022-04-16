//
//  LocationDetailsController.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/12/22.
//

import UIKit
import MapKit

class LocationDetailsController: UIViewController {
    
    // MARK: - Properties
    
    var studentCoordinate: CLLocationCoordinate2D?
    var mapString: String?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mediaURLTextField: UITextField!
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        showPinAndZoomMap()
    }
    
    // MARK: - IBActions
    
    @IBAction func handleSubmit() {
        guard let mediaURL = mediaURLTextField.text else { return }
        guard let studentCoordinate = studentCoordinate, let mapString = mapString else { return }

        UdacityClient.getUserData { success, error in
            if error != nil {
                self.showError(title: "Failed to fetch user data, please try again.", message: error?.localizedDescription ?? "")
            } else {
                UdacityClient.postStudentLocation(student: studentCoordinate, mapString: mapString, mediaURL: mediaURL, completion: self.handlePostStudentLocationResponse(success:error:))
            }
        }
    }
    
    @IBAction func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    
    func handlePostStudentLocationResponse(success: Bool, error: Error?) -> Void {
        if let error = error {
            showError(title: "Something went wrong, unable to post location.", message: error.localizedDescription)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func setupViews() {
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        let attributedString = NSAttributedString(string: "Enter a Link To Share Here",
                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        mediaURLTextField.attributedPlaceholder = attributedString
    }
    
    func showPinAndZoomMap() {
        guard let studentCoordinate = studentCoordinate else { return }
        let placeMark = MKPlacemark(coordinate: studentCoordinate)
        mapView.addAnnotation(placeMark)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: studentCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
