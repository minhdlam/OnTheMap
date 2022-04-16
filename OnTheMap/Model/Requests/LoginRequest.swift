//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/5/22.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginCredentials: Codable {
    let udacity: [String: String]
}
