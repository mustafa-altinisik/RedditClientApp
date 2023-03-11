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
        
        subredditLabel.text = "r/" + subredditName
        
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


