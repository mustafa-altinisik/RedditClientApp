//
//  TrendingPostCollectionViewCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit

// This class is used for the cells in the trendingPostsCollectionView.
// Each cell displays a single trending Reddit post.
final class TrendingPostCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var trendingPostImage: UIImageView!
    @IBOutlet private weak var trendingPostLabel: UILabel!

    // This function is used to configure the cell.
    func configureCell(title: String, imageURL: String?) {
        trendingPostLabel.text = title
        guard let isUrl = imageURL?.isImageURL(), isUrl else {
            trendingPostImage.image = UIImage(named: "no-image")
            return
        }
        guard let imageURL = URL(string: imageURL ?? "") else { return }
        DispatchQueue.main.async {
            NetworkManager.shared.getPostImage(from: imageURL) { (image, error) in
                if let image = image {
                    self.trendingPostImage.image = image
                } else if error != nil {
                    self.trendingPostImage.image = UIImage(named: "no-image")
                }
            }
        }
    }
}
