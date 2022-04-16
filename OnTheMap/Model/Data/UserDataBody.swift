//
//  UserDataBody.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/15/22.
//

import Foundation

struct UserDataBody: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
