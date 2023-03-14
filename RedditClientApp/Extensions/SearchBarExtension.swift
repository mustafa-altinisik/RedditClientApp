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
        // Remove trimming characters.
        guard var subreddit = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !subreddit.isEmpty else {
            return
        }
        // Capitalize each word except the first one for camel casing.
        subreddit = subreddit.components(separatedBy: .whitespaces).enumerated().map { (index, word) in
            return index == 0 ? word : word.capitalized
        }.joined()
        showPostsScreen(subredditToBeDisplayed: subreddit)
    }
}
