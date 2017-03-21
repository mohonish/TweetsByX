//
//  APIController.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 20/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation
import UIKit

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
            
            guard let tokenType = response["token_type"] as? String,
                let accessToken = response["access_token"] as? String else {
                    failure(APIError(errorType: APIErrorType.unauthorized))
                    return
            }
            
            if tokenType == "bearer" {
                Constants.accessToken = accessToken
                success()
            } else {
                failure(APIError(errorType: APIErrorType.unauthorized))
            }
            
        }, failure: failure)
    }
    
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
    
    fileprivate static func GET(url: String, parameters: [String: Any]?, success: @escaping (_ response: [Dictionary<String, Any>]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        guard var url = URL(string: url) else {
            failure(APIError(errorType: .invalidURL))
            return
        }
        
        if let params = parameters {
            let paramString = params.stringFromHttpParameters()
            if let newURL = URL(string: "\(url)?\(paramString)") {
                url = newURL
            }
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
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
    
    fileprivate static func POST(url: String, headers: Dictionary<String, String>?, success: @escaping (_ response: [String: Any]) -> Void, failure: @escaping (_ error: APIError) -> Void) {
        
        guard let url = URL(string: url) else {
            failure(APIError(errorType: .invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
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

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
