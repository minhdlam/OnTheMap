//
//  APIManager.swift
//  OnTheMap
//
//  Created by Duc Lam on 4/3/22.
//

import Foundation
import CoreLocation

class UdacityClient {
    
    struct Auth {
        static var sessionId = ""
        static var accountKey = ""
        static var objectId = ""
        static var uniqueKey = ""
        static var firstName = ""
        static var lastName = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case logout
        case getStudentLocations
        case getUserData
        case postStudentLocation
        
        var stringValue: String
        {
            switch self {
            case .login: return Endpoints.base + "/session"
            case .logout: return Endpoints.base + "/session"
            case .getStudentLocations: return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .getUserData: return Endpoints.base + "/users" + "/\(Auth.accountKey)"
            case .postStudentLocation: return Endpoints.base + "/StudentLocation"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL,
                                                          responseType: ResponseType.Type,
                                                          methodType: String,
                                                          completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            var newData: Data
            
            if methodType == "getUserData" {
                let range = 5..<data.count
                newData = data.subdata(in: range)
            } else {
                newData = data
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL,
                                                                                   responseType: ResponseType.Type,
                                                                                   body: RequestType,
                                                                                   completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                
                do {
                    let newResponse = try decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(newResponse, nil)
                    }
                } catch {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: newData)
                        DispatchQueue.main.async {
                            completion(nil, errorResponse)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
             
                }
            }
        }
        task.resume()
    }
    
    class func login(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = LoginCredentials(udacity: ["username": username, "password": password])
        
        taskForPOSTRequest(url: UdacityClient.Endpoints.login.url, responseType: LoginResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.accountKey = response.account.key
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        let url = UdacityClient.Endpoints.logout.url
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            Auth.sessionId = ""
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }
        task.resume()
    }
    
    class func getStudentLocations(completion: @escaping ([StudentLocationResponse], Error?) -> Void) {
        taskForGETRequest(url: UdacityClient.Endpoints.getStudentLocations.url, responseType: AllStudentsLocationResponse.self, methodType: "getStudentLocations") { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    class func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        taskForGETRequest(url: UdacityClient.Endpoints.getUserData.url, responseType: UserData.self, methodType: "getUserData") { response, error in
            if let response = response {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                Auth.uniqueKey = response.uniqueKey
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    class func postStudentLocation(student coordinate: CLLocationCoordinate2D, mapString: String, mediaURL: String, completion: @escaping(Bool, Error?) -> Void) {
        let body = UserDataBody(uniqueKey: Auth.uniqueKey, firstName: Auth.firstName, lastName: Auth.lastName, mapString: mapString, mediaURL: mediaURL, latitude: coordinate.latitude, longitude: coordinate.longitude)
        taskForPOSTRequest(url: UdacityClient.Endpoints.postStudentLocation.url, responseType: PostLocationResponse.self, body: body) { response, error in
            if let response = response {
                Auth.objectId = response.objectId
                
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }
}
