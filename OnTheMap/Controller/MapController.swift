//
//  MapController.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/12/22.
//

import UIKit
import MapKit

private let postLocationIdentifier = "postLocationFromMapView"
private let pinId = "pin"


class MapController: UIViewController {
    
    // MARK: - Properties
    
    var annotations = [MKPointAnnotation]()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        UdacityClient.getStudentLocations(completion: handleStudentLocationsResponse(studentLocations:error:))
    }
    
    // MARK: - IBActions
    
    @IBAction func handlePostLocation() {
        let postLocationController = storyboard?.instantiateViewController(withIdentifier: postLocationIdentifier) as! PostLocationController
        navigationController?.pushViewController(postLocationController, animated: true)
    }
    
    @IBAction func handleLogout() {
        UdacityClient.logout(completion: handleLogoutResponse(success:error:))
    }
    
    // MARK: - Helper Methods
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        if success {
            dismiss(animated: true)
        } else {
            guard let error = error else { return }
            showError(title: "Had trouble logging out student.", message: error.localizedDescription)
        }
    }
    
    func handleStudentLocationsResponse(studentLocations: [StudentLocationResponse], error: Error?) -> Void {
        if let error = error {
            showError(title: "Unable to load student locations at this time, please try again.", message: error.localizedDescription)
        } else {
            for studentLocation in studentLocations {
                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let firstName = studentLocation.firstName
                let lastName = studentLocation.lastName
                let mediaURL = studentLocation.mediaURL
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(firstName) \(lastName)"
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
            
            mapView.addAnnotations(annotations)
        }
    }
    
    func setupViews() {
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                guard let url = URL(string: toOpen!) else { return }
                UIApplication.shared.open(url)
            }
        }
    }
}
