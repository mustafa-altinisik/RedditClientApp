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
    func configureCell(title: String, image: UIImage?, description: String) {
        postTitle.text = title
        postImage.image = image
        postDescription.text = description
    }
}
