//
//  PostsScreenViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit
import Lottie

// This class is used to display the posts of a subreddit
final class PostsScreenViewContoller: BaseViewController {

    @IBOutlet private weak var subredditLabel: UILabel!
    @IBOutlet private weak var postsTable: UITableView!
    @IBOutlet private weak var favoriteButton: UIButton!

    // Defalults is used to store data in the device.
    private let defaults = UserDefaults.standard
    private var doesUserWantSafeSearch: Bool = false
    private var doesUserWantPostsWithImagesOnly = false
    private var favoriteSubreddits: [String] = []

    private var postsArray: [RedditPostData] = []
    var subredditName: String = ""

    @IBAction private func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }

    // This function is used to add or remove a subreddit from the favoriteSubreddits array.
    @IBAction private func favoriteButtonTapped(_ sender: Any) {
        if favoriteSubreddits.contains(subredditName) {
            favoriteSubreddits.removeAll(where: {$0 == subredditName})
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            favoriteSubreddits.append(subredditName)
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        defaults.set(favoriteSubreddits, forKey: UserDefaultsKeys.favoriteSubreddits)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the variables from the device.
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.favoriteSubreddits) {
            favoriteSubreddits = savedSubreddits
        }

        doesUserWantSafeSearch = defaults.bool(forKey: UserDefaultsKeys.safeSearch)
        doesUserWantPostsWithImagesOnly = defaults.bool(forKey: UserDefaultsKeys.postsWithImages)

        makeAPICall()

        if favoriteSubreddits.contains(subredditName) {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }

        subredditLabel.text = "r/" + subredditName

        postsTable.dataSource = self
        postsTable.delegate = self

        postsTable.register(UINib(nibName: "PostsTableViewCell", bundle: nil), forCellReuseIdentifier: "postCell")
        postsTable.rowHeight = UITableView.automaticDimension
    }
    // This function is used to make the API call to get the posts of a subreddit.
    private func makeAPICall() {
        let (animationView, overlayView) = displayRedditLogoAnimation()
        fetchRedditPosts(subredditName: subredditName, safeSearch: doesUserWantSafeSearch, onlyPostsWithImages: doesUserWantPostsWithImagesOnly) { result in
            switch result {
            case .success(let redditPosts):
                self.postsArray = redditPosts
                DispatchQueue.main.async {
                    self.postsTable.reloadData()
                    self.hideRedditLogoAnimation(animation: (animationView, overlayView))
                }
            case .failure(let error):
                print("Error fetching Reddit posts:", error.localizedDescription)
            }
        }
    }
}

// This extension is used to handle the postsTable in the PostsScreenViewContoller.
extension PostsScreenViewContoller: UITableViewDataSource, UITableViewDelegate {
    // This function returns the number of posts that will be displayed on the posts screen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }

    // This function puts the data of the posts into the cells of the posts screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostsTableViewCell else {
            fatalError("Unable to dequeue PostsTableViewCell")
        }

        let post = postsArray[indexPath.row]
        cell.configureCell(title: post.title, imageURLToBeSet: post.imageURL, description: post.description)
        return cell
    }

    // This function opens the post on the reddit website when the user taps on a post
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = postsArray[indexPath.row]
        if post.permalink != ""{
            displayRedditPost(postToBeDisplayed: post)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
