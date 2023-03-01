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
    
    //postsArray comes from the HomeScreen, it contains the posts of the subreddit that the user has selected
    var postsArray : [RedditPost] = []
    var subredditName : String = ""

    //This function dissmisses the posts screen when the user presses the back button
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subredditName = "r/" + subredditName
        subredditLabel.text = subredditName
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
        if let permalink = post.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.reddit.com/\(permalink)") {
            UIApplication.shared.open(url)
        }
    }

}


