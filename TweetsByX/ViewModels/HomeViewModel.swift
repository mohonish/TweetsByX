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
    
    var isLoadingMore = false //Whether more tweets are being loaded currently.
    var currentMaxID: String? //Current max_id value, which determines the last (oldest) tweet fetched.
    
    var tweets = [Tweet]() { //All fetched Tweets
        didSet {
            self.delegate?.reloadData() //Reload view whenever tweets list updates.
        }
    }
    
    //Authenticate with Twitter to receive auth token.
    public func authenticate() {
        APIController.getAuthToken(success: { [weak self] (response) in
            self?.loadInitialTweets()
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
    //Load latest tweets.
    public func loadInitialTweets() {
        APIController.fetchTweetsSince(since_id: nil, success: { [weak self] (response) in
            
            if let newTweets = self?.parseTweets(json: response) {
                self?.tweets = newTweets
            }
            
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
    //Load older tweets.
    public func loadPreviousTweets() {
        
        guard let maxID = self.tweets.last?.id else {
            return
        }
        
        if maxID == self.currentMaxID {
            return
        } else {
            self.currentMaxID = maxID
        }
        
        self.isLoadingMore = true
        APIController.fetchTweetsBefore(max_id: maxID, success: { [weak self] (response) in
            
            if var newTweets = self?.parseTweets(json: response) {
                newTweets.removeFirst() //Fix for inclusive max_id tweet returned. 
                self?.tweets.append(contentsOf: newTweets)
            }
            self?.isLoadingMore = false
            
        }, failure: { [weak self] (error) in
            self?.isLoadingMore = false
            print("\nError: \n\(error.errorMessage)")
        })
        
    }
    
}

// Extension for private methods.
extension HomeViewModel {
    
    //Parse list of tweets from json response.
    fileprivate func parseTweets(json: [Dictionary<String, Any>]) -> [Tweet] {
        var tweets = [Tweet]()
        for element in json {
            let thisTweet = Tweet(json: element)
            tweets.append(thisTweet)
        }
        return tweets
    }
    
}
