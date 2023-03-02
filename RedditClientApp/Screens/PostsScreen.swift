//
//  PostsScreen.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation
import UIKit

//This class is used to display the posts of a subreddit
class PostsScreen: UIViewController {
    
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var postsTable: UITableView!
    @IBOutlet weak var safeSearchSwitch: UISwitch!
    
    //postsArray comes from the HomeScreen, it contains the posts of the subreddit that the user has selected
    var postsArray : [RedditPost] = []
    var subredditName : String = ""
    
    //Defaults is used to save the user's preference for safe search
    let defaults = UserDefaults.standard
    //This preference also applies to the HomeScreen's viewController
    var doesUserWantSafeSearch: Bool = false
    
    func filterSafePosts(posts: [RedditPost]) -> [RedditPost] {
        var safePosts : [RedditPost] = []
        for post in posts {
            if post.over_18 == false {
                safePosts.append(post)
            }else{
                var updatedPost = post
                updatedPost.title = "Not Safe"
                updatedPost.description = "Please change your search preferences to see."
                updatedPost.imageURL = ""
                updatedPost.permalink = ""
                safePosts.append(updatedPost)
                //Create an instance of HomeScreen
                let homeScreen = HomeScreen()
                homeScreen.makeRedditAPICall(subreddit: subredditName, maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)


            }
        }
        return safePosts
    }


    //Show main screen with the segue "toMainScreen"
    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toMainScreen", sender: self)
    }


    @IBAction func safeSearchSwitchValueChanged(_ sender: Any) {
        //Get the current value of the safe search switch and save it to doesUserWantSafeSearch
        doesUserWantSafeSearch = safeSearchSwitch.isOn
        defaults.set(doesUserWantSafeSearch, forKey: "safeSearch")
        defaults.synchronize()   
        //Reload the whole screen to show the posts with the new safe search preference
        postsTable.reloadData()    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subredditName = "r/" + subredditName
        subredditLabel.text = subredditName
        postsTable.dataSource = self
        postsTable.delegate = self

        //Get the user's preference for safe search from the defaults and set the value of the safe search switch accordingly
        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        safeSearchSwitch.isOn = doesUserWantSafeSearch
    }
}

//MARK: - This extension contains the functions that are used to display the posts on the posts screen
extension PostsScreen: UITableViewDataSource, UITableViewDelegate {
    //This function returns the number of posts that will be displayed on the posts screen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    //This function puts the data of the posts into the cells of the posts screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell") as! PostsTableViewCell
        
        if(doesUserWantSafeSearch){
            postsArray = filterSafePosts(posts: postsArray)
        }
        
        let post = postsArray[indexPath.row]

        let imageURL = URL(string: post.imageURL)
        let imageView = cell.postImage
        
        imageView?.contentMode = .scaleAspectFit

        cell.postDescription.text = post.description
        cell.postTitle.text = post.title
        
        //DispatchQueue.global().async is used to download the images in the background.
        DispatchQueue.global().async {
            if let url = imageURL, let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let imageView = imageView {
                            imageView.image = image
                        }
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


