//
//  FavoriteSubredditTVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 10.03.2023.
//

import UIKit

// This class is used for the cells in the favoriteSubredditsTableView 
class FavoriteSubredditTVC: UITableViewCell {
    @IBOutlet weak var favoriteSubredditLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
