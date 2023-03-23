//
//  FavoriteSubredditTableViewCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 10.03.2023.
//

import UIKit

// This class is used for the cells in the favoriteSubredditsTableView 
final class FavoriteSubredditTableViewCell: UITableViewCell {
    @IBOutlet private weak var favoriteSubredditLabel: UILabel!
    
    // This function is used to configure the cell.
    func configureCell(subreddit: String) {
        favoriteSubredditLabel.text = subreddit
    }

}
