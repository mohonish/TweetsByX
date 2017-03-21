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
        
        public static let twitterHandle = "FlohNetwork"
        public static let pageCount = 10
        
    }
    
    public struct Twitter {
        
        public static let apiKey: String      = "Vttg7K8Uk70E1SwQddFVBZ9GO"
        public static let apiSecret: String   = "qOrHrkrCo36mNNcglAbPjwS044wNzr0zruCVvAARfYRwmlT5yb"
        
    }
    
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
