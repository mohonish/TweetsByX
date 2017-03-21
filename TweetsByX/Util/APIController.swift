//
//  APIController.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 20/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

// NOTE:
// Networking manager to handle authentication and GET/POST requests.

import Foundation
import UIKit

//Generic API Error Class. Modify and extend for future cases.
public struct APIError {
    
    var errorMessage = "Oops! Something went wrong. Please try again."
    var errorType: APIErrorType
    
    public init(errorType: APIErrorType) {
        self.errorType = errorType
    }
    
    public init(errorMessage: String, errorType: APIErrorType) {
        self.errorMessage = errorMessage
        self.errorType = errorType
    }
}

//Enum for all known error cases from the frontend.
public enum APIErrorType {
    case invalidURL, noResponseData, jsonSerializationFail, errorResponse, unauthorized
}

public class APIController {
    
    fileprivate static let authEndpoint     = "https://api.twitter.com/oauth2/token?grant_type=client_credentials"
    fileprivate static let tweetsEndpoint   = "https://api.twitter.com/1.1/statuses/user_timeline.json"
    
    public static func getAuthToken(success: @escaping () -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        var bearerCredential = Constants.Twitter.apiKey + ":" + Constants.Twitter.apiSecret
        bearerCredential = Data(bearerCredential.utf8).base64EncodedString()
        
        let headers = [
            "Authorization" :   "Basic \(bearerCredential)",
            "Content-Type"  :   "application/x-www-form-urlencoded;charset=UTF-8"
        ]
        
        POST(url: authEndpoint, headers: headers, success: { (response) in
            
            //Parse authorization access token from response.
            guard let tokenType = response["token_type"] as? String,
                let accessToken = response["access_token"] as? String else {
                    failure(APIError(errorType: APIErrorType.unauthorized))
                    return
            }
            
            if tokenType == "bearer" {
                Constants.accessToken = accessToken //Set current access token.
                success()
            } else {
                failure(APIError(errorType: APIErrorType.unauthorized))
            }
            
        }, failure: failure)
    }
    
    //Use to fetch latest tweets.
    //since_id would be the ID of the latest tweet already fetched. Returns new tweets if any.
    public static func fetchTweetsSince(since_id: String?, success: @escaping (_ response: [Dictionary<String, Any>]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        var parameters: [String: Any] = [
            "screen_name"   : Constants.Config.twitterHandle,
            "count"         : String(Constants.Config.pageCount)
        ]
        if let sinceID = since_id {
            parameters["since_id"] = sinceID
        }
        
        GET(url: tweetsEndpoint, parameters: parameters, success: success, failure: failure)
        
    }
    
    //Use to fetch older tweets (as user scrolls down).
    //max_id is the ID of the oldest tweet that was already fetched (last tweet in the list sorted from new to old tweets).
    public static func fetchTweetsBefore(max_id: String, success: @escaping (_ response: [Dictionary<String, Any>]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        let parameters: [String: Any] = [
            "screen_name"   : Constants.Config.twitterHandle,
            "count"         : String(Constants.Config.pageCount),
            "max_id"        : max_id
        ]
        
        GET(url: tweetsEndpoint, parameters: parameters, success: success, failure: failure)
        
    }
    
}

extension APIController {
    
    //GET implementation
    fileprivate static func GET(url: String, parameters: [String: Any]?, success: @escaping (_ response: [Dictionary<String, Any>]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        guard var url = URL(string: url) else {
            failure(APIError(errorType: .invalidURL))
            return
        }
        
        //URLEncode parameters if any
        if let params = parameters {
            let paramString = params.stringFromHttpParameters()
            if let newURL = URL(string: "\(url)?\(paramString)") {
                url = newURL
            }
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        //Set Authorization token.
        if let token = Constants.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let _ = error {
                failure(APIError(errorType: .errorResponse))
                return
            }
            
            guard let responseData = data else {
                failure(APIError(errorType: .noResponseData))
                return
            }
            
            do {
                guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [Dictionary<String, Any>] else {
                    failure(APIError(errorType: .jsonSerializationFail))
                    return
                }
                success(responseJSON)
                
            } catch {
                failure(APIError(errorType: .jsonSerializationFail))
                return
            }
            
        })
        task.resume()
    }
    
    //POST implementation.
    fileprivate static func POST(url: String, headers: Dictionary<String, String>?, success: @escaping (_ response: [String: Any]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        guard let url = URL(string: url) else {
            failure(APIError(errorType: .invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        //Set headers if any
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let _ = error {
                failure(APIError(errorType: .errorResponse))
                return
            }
            
            guard let responseData = data else {
                failure(APIError(errorType: .noResponseData))
                return
            }
            
            do {
                guard let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    failure(APIError(errorType: .jsonSerializationFail))
                    return
                }
                success(responseJSON)
                
            } catch {
                failure(APIError(errorType: .jsonSerializationFail))
                return
            }
            
        })
        task.resume()
    }
    
}

//NOTE: Extensions used primarily to create valid url encoded strings.

extension String {
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
