//
//  TrendingCarouselCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit

class TrendingCarouselCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        textLabel.textAlignment = .center
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        textLabel.frame = CGRect(x: 0, y: contentView.bounds.size.height - 30, width: contentView.bounds.size.width, height: 30)
    }
}
