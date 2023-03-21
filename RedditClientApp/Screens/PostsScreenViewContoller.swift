//
//  PostsScreenViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit
import Lottie

// This class is used to display the posts of a subreddit
final class PostsScreenViewContoller: UIViewController {
    
    @IBOutlet private weak var subredditLabel: UILabel!
    @IBOutlet private weak var postsTable: UITableView!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    private var networkManager = NetworkManager()
    private var baseClass = BaseViewController()
    //123123 bakarsin
    private var animationView: LottieAnimationView?

    
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
        
        // Load the variables from the device.
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }
        
        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        doesUserWantPostsWithImagesOnly = defaults.bool(forKey: "postsWithImages")
        
                
        makeAPICall()
        
        
        if favoriteSubreddits.contains(subredditName) {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        subredditLabel.text = "r/" + subredditName
        
        postsTable.dataSource = self
        postsTable.delegate = self
    }
    // This function is used to make the API call to get the posts of a subreddit.
    private func makeAPICall() {
        let redditAnimation = baseClass.displayRedditLogoAnimation()
        postsTable.addSubview(redditAnimation)
        
        networkManager.getRedditPostsFromSubreddit(subredditName: subredditName,
                                                   safeSearch: doesUserWantSafeSearch,
                                                   onlyPostsWithImages: doesUserWantPostsWithImagesOnly) { [weak self] (posts, error) in
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
                self.baseClass.hideRedditLogoAnimation(redditAnimation)
                self.postsTable.reloadData()
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
        
        if let imageURL = URL(string: post.imageURL) {
            networkManager.getPostImage(from: imageURL) { image, error in
                DispatchQueue.main.async {
                    cell.configureCell(title: post.title, image: image, description: post.description)
                }
            }
        } else {
            cell.configureCell(title: post.title, image: nil, description: post.description)
        }
        
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
    
    //123123 xib olusturduktan sonra acarsin
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
}
