//
//  PostsScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation
import UIKit

// This class is used to display the posts of a subreddit
class PostsScreenVC: UIViewController {

    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var favoriteButton: UIButton!

    var redditAPI = RedditAPI()

    // Defalults is used to store data in the device.
    let defaults = UserDefaults.standard
    var doesUserWantSafeSearch: Bool = false
    var favoriteSubreddits: [String] = []

    var postsArray: [RedditPost] = []
    var subredditName: String = ""

    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toHomeScreen", sender: self)
    }

    // This function is used to add or remove a subreddit from the favoriteSubreddits array.
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if favoriteSubreddits.contains(subredditName) {// If the subreddit is already in the array, remove it.
            favoriteSubreddits.removeAll(where: {$0 == subredditName})
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        } else {// If the subreddit is not in the array, add it.
            favoriteSubreddits.append(subredditName)
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        // Save the favoriteSubreddits array to the device.
        defaults.set(favoriteSubreddits, forKey: "favoriteSubreddits")
        defaults.synchronize()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeAPICall()

        // Load the variables from the device.
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }

        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")

        if favoriteSubreddits.contains(subredditName) {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }

        subredditLabel.text = "r/" + subredditName

        postsTable.dataSource = self
        postsTable.delegate = self
    }
    // This function is used to make the API call to get the posts of a subreddit.
    private func makeAPICall() {
        redditAPI.getRedditPostsFromSubreddit(subredditName: subredditName,
                                              safeSearch: doesUserWantSafeSearch,
                                              onlyPostsWithImages: false) { [weak self] (posts, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error retrieving Reddit posts: \(error.localizedDescription)")
                return
            }
            guard let posts = posts else {
                print("No posts retrieved")
                return
            }
            self.postsArray = posts
            DispatchQueue.main.async {
                self.postsTable.reloadData()
            }
        }
    }
}
