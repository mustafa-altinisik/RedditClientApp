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
    @IBOutlet weak var favoriteButton: UIButton!
    
    //defalults is used to store data in the device.
    let defaults = UserDefaults.standard
    
    //postsArray comes from the HomeScreen, it contains the posts of the subreddit that the user has selected.
    var postsArray : [RedditPost] = []
    
    var subredditName : String = ""
    
    //This array is used to store favorite subreddits.
    var favoriteSubreddits : [String] = []
    
    //Create an array to hold predefined categories to exclude from the favorite subreddits.
    let subredditsToBeExcluded : [String] = ["trendings", "technology", "photography", "science", "computers", "news"]
    
    //Show main screen with the segue "toMainScreen"
    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toMainScreen", sender: self)
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
    
    //This function is used to pass the favoriteSubreddits array to the HomeScreen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMainScreen" {
            let destinationVC = segue.destination as! HomeScreen
            destinationVC.favoriteSubreddits = self.favoriteSubreddits
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Traverse the favoriteSubreddits array and check if the subredditName is in the array, if it is, make the favorite button filled star.
        if favoriteSubreddits.contains(subredditName) {
            //Make the favorite button red
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
        //If subredditName is in the subredditsToBeExluded array, make the favorite button invisible
        if subredditsToBeExcluded.contains(subredditName) {
            favoriteButton.isHidden = true
        }
        
        //Display the subreddit name on the posts screen
        let subredditNameToBeDisplayed = "r/" + subredditName
        subredditLabel.text = subredditNameToBeDisplayed
        postsTable.dataSource = self
        postsTable.delegate = self
        
        
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


