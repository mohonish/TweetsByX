//
//  HomeViewController.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 20/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.handlePullToRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "@" + Constants.Config.twitterHandle
        
        self.viewModel.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        self.tableView.addSubview(self.refreshControl)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.authenticate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Pull To Refresh
    
    func handlePullToRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel.loadInitialTweets()
    }

}

extension HomeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as! TweetTableViewCell
        let thisTweet = viewModel.tweets[indexPath.row]
        cell.headerLabel.text = thisTweet.username
        cell.bodyLabel.text = thisTweet.text
        cell.tweetImageView.kf.setImage(with: thisTweet.profileImageURL)
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollContentHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        let scrollBottomPosition = scrollView.contentOffset.y + scrollView.bounds.size.height
        let difference = scrollContentHeight - scrollBottomPosition
        
        if difference < 200 && !self.viewModel.isLoadingMore {
            print("loadMore")
            self.viewModel.loadPreviousTweets()
        }
        
    }
    
}

extension HomeViewController: HomeViewModelProtocol {
    
    func reloadData() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        })
    }
    
}

