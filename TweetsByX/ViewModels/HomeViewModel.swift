//
//  HomeViewModel.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 21/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public protocol HomeViewModelProtocol: class {
    func reloadData()
}

public class HomeViewModel {
    
    weak var delegate: HomeViewModelProtocol?
    
    var tweets = [Tweet]() {
        didSet {
            self.delegate?.reloadData()
        }
    }
    
    public func authenticate() {
        APIController.getAuthToken(success: { [weak self] (response) in
            self?.loadInitialTweets()
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
    public func loadInitialTweets() {
        APIController.fetchTweetsSince(since_id: nil, success: { [weak self] (response) in
            
            if let newTweets = self?.parseTweets(json: response) {
                self?.tweets = newTweets
            }
            
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
}

extension HomeViewModel {
    
    fileprivate func parseTweets(json: [Dictionary<String, Any>]) -> [Tweet] {
        var tweets = [Tweet]()
        for element in json {
            let thisTweet = Tweet(json: element)
            tweets.append(thisTweet)
        }
        return tweets
    }
    
}
