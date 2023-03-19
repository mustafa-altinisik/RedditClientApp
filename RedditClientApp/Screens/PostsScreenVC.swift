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

    var redditAPI = NetworkManager()

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


// This extension is used to handle the postsTable in the PostsScreenVC.
extension PostsScreenVC: UITableViewDataSource, UITableViewDelegate {
    // This function returns the number of posts that will be displayed on the posts screen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }

    // This function puts the data of the posts into the cells of the posts screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostsTVC else {
            fatalError("Unable to dequeue PostsTVC")
        }

        let post = postsArray[indexPath.row]

        if let imageURL = URL(string: post.imageURL) {
            redditAPI.getPostImage(from: imageURL) { image, error in
                guard let image = image, error == nil else {
                    print("Error downloading image: \(error!)")
                    return
                }
                DispatchQueue.main.async {
                    cell.postImage?.image = image
                }
            }
        } else {
            cell.postImage?.image = nil
        }

        cell.postDescription.text = post.description
        cell.postTitle.text = post.title

        return cell
    }

    // This function opens the post on the reddit website when the user taps on a post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = postsArray[indexPath.row]
        if post.permalink != ""{
            if let permalink = post.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.reddit.com/\(permalink)") {
                UIApplication.shared.open(url)
            }
        }
    }
}
