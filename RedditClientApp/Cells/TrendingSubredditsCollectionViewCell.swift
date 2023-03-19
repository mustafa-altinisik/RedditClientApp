//
//  TrendingSubredditsCVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit

// This class is used for the cells in the trendingSubredditsTableView 
// Each cell displays a single trending subreddit.
final class TrendingSubredditsCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var trendingSubredditImage: UIImageView!
    @IBOutlet private weak var trendingSubredditLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(title: String, image: UIImage?) {
        trendingSubredditImage.image = image
        trendingSubredditLabel.text = title
    }
    
    func getSubredditLabel() -> String? {
        return trendingSubredditLabel.text
    }
}
