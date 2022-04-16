//
//  StudentLocationResponse.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/13/22.
//

import Foundation

struct StudentLocationResponse: Codable {
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
}
