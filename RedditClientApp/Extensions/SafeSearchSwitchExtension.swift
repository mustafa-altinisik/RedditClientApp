//
//  SafeSearchSwitchExtension.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

// This extension is used to handle the safe search switch in the MainScreenVC.
extension MainScreenVC {
    @IBAction func safeSearchSwitchValueChanged(_ sender: UISwitch) {
        doesUserWantSafeSearch = safeSearchSwitch.isOn
        defaults.set(doesUserWantSafeSearch, forKey: "safeSearch")
        defaults.synchronize()

        // Call the API again with the updated safe search option
        redditAPI.getRedditPostsFromSubreddit(subredditName: "popular",
                                              safeSearch: sender.isOn,
                                              onlyPostsWithImages: true) { (posts, error) in
            if let error = error {
                print("Error retrieving Reddit posts: \(error.localizedDescription)")
                return
            }

            guard let posts = posts else {
                print("No posts retrieved")
                return
            }

            self.trendingPosts = posts

            DispatchQueue.main.async {
                self.trendingPostsCollectionView.reloadData()
            }
        }
    }
}
