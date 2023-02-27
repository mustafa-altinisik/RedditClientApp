//
//  TrendingCarouselCell.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import UIKit

//This class is used to create a single cell for the trending posts carousel in the main screen.
//The design is done programmatically.
class TrendingCarouselCell: UICollectionViewCell {
    
    //Create the image view and the label that will be used to display the image and the title of the post.
    let imageView = UIImageView()
    let textLabel = UILabel()
    
    //This function initializes the cell with the given frame.
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
    
    //This function sets the properties of the cell.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        textLabel.frame = CGRect(x: 0, y: contentView.bounds.size.height - 30, width: contentView.bounds.size.width, height: 30)
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 8.0
        
    }
}
