//
//  HomeViewModel.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 21/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import Foundation

public protocol HomeViewModelProtocol: class {
    
}

public class HomeViewModel {
    
    weak var delegate: HomeViewModelProtocol?
    
    private var currentPage = -1
    
    public func authenticate() {
        APIController.getAuthToken(success: { [weak self] (response) in
            self?.loadTweets()
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
    public func loadTweets() {
        APIController.fetchTweetsSince(since_id: nil, success: { (response) in
            print("\nRESPONSE:\n\(response)")
        }, failure: { (error) in
            print("\nError: \n\(error.errorMessage)")
        })
    }
    
}
