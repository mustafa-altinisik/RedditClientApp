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

    // This function is used to configure the cell.
    func configureCell(title: String, image: UIImage?) {
        trendingSubredditImage.image = image
        trendingSubredditLabel.text = title
    }
    
    // This function is used to get the subreddit label.
    func getSubredditLabel() -> String? {
        return trendingSubredditLabel.text
    }
}
