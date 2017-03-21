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

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Class Members
    
    //Refresh control for pull to refresh.
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HomeViewController.handlePullToRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //View model
    let viewModel = HomeViewModel()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setDelegates()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.authenticate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup
    
    func setupUI() {
        //Navigation Bar Title
        self.title = "@" + Constants.Config.twitterHandle
        //Add further UI customization if required.
    }
    
    func setDelegates() {
        //View model delegate
        self.viewModel.delegate = self
        //Tableview delegate and datasource
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        self.tableView.addSubview(self.refreshControl)
    }
    
    //MARK: - Pull To Refresh
    
    func handlePullToRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel.loadInitialTweets()
    }

}

// MARK: - UITableView DataSource

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

// MARK: - UIScrollView + UITableView Delegate

extension HomeViewController: UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollContentHeight = scrollView.contentSize.height + scrollView.contentInset.bottom
        let scrollBottomPosition = scrollView.contentOffset.y + scrollView.bounds.size.height
        let difference = scrollContentHeight - scrollBottomPosition
        
        //Difference determines the offset remaining to reach the bottom from user's current position.
        //We trigger load more when the difference is reached to enable smooth scrolling, considering a user's normal reading pace.
        if difference < 200 && !self.viewModel.isLoadingMore {
            self.viewModel.loadPreviousTweets() //Load more tweets
        }
        
    }
    
}

extension HomeViewController: HomeViewModelProtocol {
    
    //Used by view model to update view whenever data changes.
    func reloadData() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        })
    }
    
}

