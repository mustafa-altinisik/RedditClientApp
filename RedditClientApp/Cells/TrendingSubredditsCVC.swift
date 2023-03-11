//
//  TrendingSubredditsCVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit

// This class is used for the cells in the trendingSubredditsTableView 
// Each cell displays a single trending subreddit.
class TrendingSubredditsCVC: UICollectionViewCell {

    @IBOutlet weak var trendingSubredditImage: UIImageView!
    @IBOutlet weak var trendingSubredditLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
