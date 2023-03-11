//
//  SearchBarExtension.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

// This extension is used to handle the search bar in the MainScreenVC.
extension MainScreenVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let subreddit = searchBar.text, !subreddit.isEmpty else {
            return
        }
        showPostsScreen(subredditToBeDisplayed: subreddit)
    }
}
