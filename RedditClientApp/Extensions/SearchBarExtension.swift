//
//  SearchBarExtension.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

extension MainScreenVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let subreddit = searchBar.text, !subreddit.isEmpty else {
            return
        }
        showPostsScreen(subredditToBeDisplayed: subreddit)
    }
}
