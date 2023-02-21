//
//  PostsScreen.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation
import UIKit

class PostsScreen: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var subredditLabel: UILabel!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var postsArray : [RedditPost] = []
    var favoriteSubreddits : [String] = []

    
    var subredditName : String = ""
    @IBOutlet weak var postsTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subredditName = "r/" + subredditName
        subredditLabel.text = subredditName
        print(subredditName)
        postsTable.dataSource = self
    }
}

extension PostsScreen: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell") as! PostsTVC        
        let post = postsArray[indexPath.row]

        let imageURL = URL(string: post.imageURL)
        let imageView = cell.postImage
        
        imageView?.contentMode = .scaleAspectFit

        
        cell.postDescription.text = post.description
        cell.postTitle.text = post.title
        
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
}
