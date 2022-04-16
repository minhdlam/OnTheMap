//
//  UserData.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/15/22.
//

import Foundation

struct UserData: Codable {
    let firstName: String
    let lastName: String
    let uniqueKey: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case uniqueKey = "key"
    }
}
