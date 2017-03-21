//
//  Constants.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 21/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public struct Constants {
    
    public struct Config {
        
        public static let twitterHandle = "FlohNetwork" //User's twitter handle without the @.
        public static let pageCount = 10                //Count of pages loaded at a time from the api call.
        
    }
    
    public struct Twitter { //Twitter App Credentials.
        
        public static let apiKey: String      = "Vttg7K8Uk70E1SwQddFVBZ9GO"
        public static let apiSecret: String   = "qOrHrkrCo36mNNcglAbPjwS044wNzr0zruCVvAARfYRwmlT5yb"
        
    }
    
    //Storage and retrieval of authorization token.
    private static let accessTokenKey = "token_access"
    public static var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: accessTokenKey)
        }
    }
    
}
