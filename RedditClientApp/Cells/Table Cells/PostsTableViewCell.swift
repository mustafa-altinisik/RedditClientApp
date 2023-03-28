//
//  PostsTableViewCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit

// This class is used for the cells in the postsTable in the PostsScreenViewContoller.
// Each cell displays a single Reddit post.
final class PostsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var postDescription: UILabel!

    // This function is used to configure the cell.
    func configureCell(title: String, imageURL: String?, description: String) {
        postTitle.text = title
        postDescription.text = description
        guard let isUrl = imageURL?.isImageURL(), isUrl else {
            postImage.image = UIImage(named: "no-image-square")
            return
        }
        
        guard let imageURL = URL(string: imageURL ?? "") else { return }
        DispatchQueue.main.async {
            NetworkManager.shared.getPostImage(from: imageURL) { (image, error) in
                if let image = image {
                    self.postImage.image = image
                } else if error != nil {
                    self.postImage.image = UIImage(named: "no-image-square")
                }
            }
        }

    }
}
