//
//  APIManager.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/3/22.
//

import Foundation

struct APIManager {
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case login
        
        var stringValue: String
        {
            switch self {
            case .login: return Endpoints.base
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
}
