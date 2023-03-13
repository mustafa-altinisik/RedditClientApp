//
//  PostsTableExtension.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

// This extension is used to handle the postsTable in the PostsScreenVC.
extension PostsScreenVC: UITableViewDataSource, UITableViewDelegate {
    //This function returns the number of posts that will be displayed on the posts screen
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    //This function puts the data of the posts into the cells of the posts screen
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
