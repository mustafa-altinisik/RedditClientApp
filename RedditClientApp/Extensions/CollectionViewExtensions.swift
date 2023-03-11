//
//  CollectionViewExtensions.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit


extension MainScreenVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trendingPostsCollectionView {
            return trendingPosts.count
        } else {
            return topSubreddits.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trendingPostsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingPostCell", for: indexPath) as! TrendingPostCVC
            let post = trendingPosts[indexPath.row]
            cell.trendingPostLabel.text = post.title
            cell.trendingPostImage.image = nil // clear the image to avoid flickering
            cell.trendingPostImage.contentMode = .scaleAspectFill // set the content mode to fill the cell
            guard let imageURL = URL(string: post.imageURL) else { return cell }
            redditAPI.getPostImage(from: imageURL) { (image, error) in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.trendingPostImage.image = image
                    }
                } else if let error = error {
                    print("Error loading post image: \(error.localizedDescription)")
                }
            }
            return cell
        }
        else {
            let systemImages = ["circle.grid.hex", "rectangle.stack","triangle","square.grid.3x1.below.line.grid.1x2", "rhombus","hexagon", "pentagon", "octagon", "star", "sun.max", "moon", "cloud", "cloud.sun", "cloud.rain", "cloud.snow", "tornado", "hurricane", "bolt", "umbrella", "flame", "drop", "waveform.path.ecg.rectangle"]
            
            if pickedIcons.count >= systemImages.count {
                return UICollectionViewCell()
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as! TrendingSubredditsCVC
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            
            if favoriteSubreddits.contains(subreddit) {
                let starSymbol = " ⭐️"
                cell.trendingSubredditLabel.text = subreddit + starSymbol
            } else {
                cell.trendingSubredditLabel.text = subreddit
            }
            
            var systemImage: UIImage?
            repeat {
                let randomIndex = Int.random(in: 0..<systemImages.count)
                let iconName = systemImages[randomIndex]
                if !pickedIcons.contains(iconName) {
                    pickedIcons.append(iconName)
                    systemImage = UIImage(systemName: iconName)
                    break
                }
            } while systemImage == nil
            
            cell.trendingSubredditImage.image = systemImage
            
            return cell
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trendingPostsCollectionView {
            let cellWidth = collectionView.bounds.width
            let cellHeight = collectionView.bounds.height
            return CGSize(width: cellWidth, height: cellHeight)
        } else {
            let cellWidth = ((collectionView.bounds.width) - 20) / 3
            let cellHeight = collectionView.bounds.height / 2
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Calculate the index of the next item
        let currentIndex = trendingPostsCollectionView.contentOffset.x / trendingPostsCollectionView.bounds.size.width
        let nextIndex = round(currentIndex)
        
        // Check if the next index is within the range of the number of items in the section
        let numberOfItemsInSection = trendingPostsCollectionView.numberOfItems(inSection: 0)
        guard nextIndex >= 0 && nextIndex < Double(numberOfItemsInSection) else {
            return
        }
        
        // Scroll to the next item with animation
        let indexPath = IndexPath(item: Int(nextIndex), section: 0)
        trendingPostsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        //Make a short vibration when fully scrolled
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trendingPostsCollectionView {
            let post = trendingPosts[indexPath.row]
            if post.permalink != ""{
                if let permalink = post.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "https://www.reddit.com/\(permalink)") {
                    UIApplication.shared.open(url)
                }
            }
        } else if collectionView == trendingSubredditsCollectionView {
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            showPostsScreen(subredditToBeDisplayed: subreddit)
        }
    }
    
}
