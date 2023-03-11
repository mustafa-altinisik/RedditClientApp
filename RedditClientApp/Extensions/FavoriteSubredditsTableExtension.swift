//
//  FavoriteSubredditsTableExtension.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

// This extension is used to handle the favoriteSubredditsTableView in the MainScreenVC.
extension MainScreenVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSubreddits.count
    }
    
    // This function is used to display the favorite subreddits in the favoriteSubredditsTableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteSubredditCell", for: indexPath) as! FavoriteSubredditTVC
        cell.favoriteSubredditLabel.text = "r/" + favoriteSubreddits[indexPath.row]
        
        return cell
    }
    
    // This function calls the showPostsScreen function when a favorite subreddit is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: favoriteSubreddits[indexPath.row])
    }
    
    
}
