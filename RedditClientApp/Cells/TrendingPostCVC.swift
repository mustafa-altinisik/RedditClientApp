//
//  TrendingPostCVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit

// This class is used for the cells in the trendingPostsCollectionView.
// Each cell displays a single trending Reddit post.
class TrendingPostCVC: UICollectionViewCell {

    @IBOutlet weak var trendingPostImage: UIImageView!
    @IBOutlet weak var trendingPostLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
