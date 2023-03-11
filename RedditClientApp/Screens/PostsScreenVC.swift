//
//  PostsScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation
import UIKit

//This class is used to display the posts of a subreddit
class PostsScreenVC: UIViewController {
    
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var redditAPI = RedditAPI()
    
    //defalults is used to store data in the device.
    let defaults = UserDefaults.standard
    var doesUserWantSafeSearch: Bool = false
    var favoriteSubreddits: [String] = []
    
    var postsArray : [RedditPost] = []
    var subredditName : String = ""
    
    //Show main screen with the segue "toMainScreen"
    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toHomeScreen", sender: self)
    }
    
    //This function is used to add or remove a subreddit from the favoriteSubreddits array.
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if(favoriteSubreddits.contains(subredditName)){
            //Remove the subreddit from the favoriteSubreddits array.
            favoriteSubreddits.removeAll(where: {$0 == subredditName})
            //Change the image of the favorite button to an empty star.
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }else{
            //Add the subreddit to the favoriteSubreddits array.
            favoriteSubreddits.append(subredditName)
            //Change the image of the favorite button to a filled star.
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        //Save the favoriteSubreddits array to the device.
        defaults.set(favoriteSubreddits, forKey: "favoriteSubreddits")
        defaults.synchronize()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeAPICall()
        
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }
        
        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        
        if favoriteSubreddits.contains(subredditName) {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        
        let subredditNameToBeDisplayed = "r/" + subredditName
        subredditLabel.text = subredditNameToBeDisplayed
        
        postsTable.dataSource = self
        postsTable.delegate = self
        
        
    }
    private func makeAPICall(){
        redditAPI.getRedditPostsFromSubreddit(subredditName: subredditName, safeSearch: doesUserWantSafeSearch, onlyPostsWithImages: false) { [weak self] (posts, error) in
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

//MARK: - This extension contains the functions that are used to display the posts on the posts screen
extension PostsScreenVC: UITableViewDataSource, UITableViewDelegate {
    //This function returns the number of posts that will be displayed on the posts screen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    //This function puts the data of the posts into the cells of the posts screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell") as! PostsTVC
        
        let post = postsArray[indexPath.row]
        
        let imageURL = URL(string: post.imageURL)
        let imageView = cell.postImage
        
        imageView?.contentMode = .scaleAspectFit
        
        cell.postDescription.text = post.description
        cell.postTitle.text = post.title
        
        if let imageURL = imageURL {
            redditAPI.getPostImage(from: imageURL) { image, error in
                guard let image = image, error == nil else {
                    print("Error downloading image: \(error!)")
                    return
                }
                DispatchQueue.main.async {
                    if let imageView = imageView {
                        imageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    
    
    //This function opens the post on the reddit website when the user taps on a post
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


