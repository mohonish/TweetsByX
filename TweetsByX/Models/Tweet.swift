//
//  Tweet.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 21/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public struct Tweet {
    
    var id: String?             //Tweet ID
    var text: String?           //Tweet body/text
    var username: String?       //Tweet user (username)
    var profileImageURL: URL?   //Tweet user image
    
    init(json: Dictionary<String, Any>) {
        if let thisID = json["id_str"] as? String {
            self.id = thisID
        }
        if let thisText = json["text"] as? String {
            self.text = thisText
        }
        if let thisUser = json["user"] as? Dictionary<String, Any>,
            let thisUsername = thisUser["screen_name"] as? String {
            self.username = thisUsername
        }
        if let thisUser = json["user"] as? Dictionary<String, Any>,
            let userImagePath = thisUser["profile_image_url"] as? String,
            let userImageURL = URL(string: userImagePath) {
            self.profileImageURL = userImageURL
        }
    }
    
}
