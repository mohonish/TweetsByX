//
//  HomeViewController.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 20/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.authenticate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension HomeViewController: HomeViewModelProtocol {
    
    func reloadData() {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.tableView.reloadData()
        })
    }
    
}

