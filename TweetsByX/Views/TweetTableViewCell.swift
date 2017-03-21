//
//  TweetTableViewCell.swift
//  TweetsByX
//
//  Created by Mohonish Chakraborty on 21/03/17.
//  Copyright © 2017 mohonish. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetImageView: UIImageView! //Use to set the tweet image content.
    
    @IBOutlet weak var headerLabel: UILabel!        //Use to set the tweet header (username or screen name)
    
    @IBOutlet weak var bodyLabel: UILabel!          //Use to set the tweet body text
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
