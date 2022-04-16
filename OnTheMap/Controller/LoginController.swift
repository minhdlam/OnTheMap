//
//  ViewController.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/3/22.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var websiteLoginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.isHidden = true
        resetTextFields()
    }
    
    // MARK: - Helper Methods
    
    func resetTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    func setViewsForLogin(_ loggingIn: Bool ) {
        activityIndicator.isHidden = !loggingIn
        loggingIn ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        websiteLoginButton.isEnabled = !loggingIn
    }
    
    func handleLoginResponse(success: Bool, error: Error?) -> Void {
        if success {
            setViewsForLogin(false)
            performSegue(withIdentifier: "login", sender: nil)
        } else {
            guard let error = error else { return }
            showError(title: "Login Failed", message: error.localizedDescription)
            setViewsForLogin(false)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func loginUser() {
        setViewsForLogin(true)
        guard let username = emailTextField.text, let password = passwordTextField.text else { return }
        UdacityClient.login(username: username, password: password, completion: handleLoginResponse(success:error:))
    }
    
    @IBAction func handleWebsiteRegistration() {
        guard let url = URL(string: "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com") else { return }
        UIApplication.shared.open(url)
    }
}
