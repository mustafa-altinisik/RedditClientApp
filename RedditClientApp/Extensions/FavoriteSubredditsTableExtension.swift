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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            let deletedSubreddit = self.favoriteSubreddits[indexPath.row]
            self.favoriteSubreddits.remove(at: indexPath.row)
            self.defaults.set(self.favoriteSubreddits, forKey: "favoriteSubreddits")
            self.defaults.synchronize()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Reload the cell if it exists in trendingSubreddits array
            if self.topSubreddits.keys.contains(deletedSubreddit) {
                let index = Array(self.topSubreddits.keys).firstIndex(of: deletedSubreddit)!
                let indexPath = IndexPath(item: index, section: 0)
                self.trendingSubredditsCollectionView.reloadItems(at: [indexPath])
            }
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    
}
