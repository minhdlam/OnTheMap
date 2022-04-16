//
//  ErrorResponse.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/5/22.
//

import Foundation

struct ErrorResponse: Codable, Error {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case statusMessage = "error"
    }
}
