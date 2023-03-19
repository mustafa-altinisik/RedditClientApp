//
//  PostsTableViewCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit

// This class is used for the cells in the postsTable in the PostsScreenVC.
// Each cell displays a single Reddit post.
final class PostsTableViewCell: UITableViewCell {

    @IBOutlet private weak var postTitle: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var postView: UIView!
    @IBOutlet private weak var postDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(title: String, image: UIImage?, description: String) {
        postTitle.text = title
        postImage.image = image
        postDescription.text = description
    }

}
