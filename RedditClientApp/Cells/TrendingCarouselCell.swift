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
        
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.backgroundColor = UIColor(white: 0, alpha: 0.5)
        textLabel.textColor = .white
        contentView.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //This function sets the properties of the cell.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        //Make textLabels height 30% of the cell's height.
        //Here is a good explanation of CGRect: https://stackoverflow.com/questions/30658045/difference-between-cgsize-and-cgrect
        textLabel.frame = CGRect(x: 0, y: contentView.bounds.size.height - (contentView.bounds.size.height * 0.3),
                                 width: contentView.bounds.size.width, height: contentView.bounds.size.height * 0.3)
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 8.0
        
    }
}
