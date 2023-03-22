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

    func configureCell(title: String, image: UIImage?) {
        trendingPostImage.image = image
        trendingPostLabel.text = title
    }
}
