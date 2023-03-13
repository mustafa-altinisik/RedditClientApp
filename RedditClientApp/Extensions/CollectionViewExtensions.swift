//
//  CollectionViewExtensions.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 11.03.2023.
//

import Foundation
import UIKit

// This extension contains functions related to two collection views: trendingPostsCV and trendingSubredditsCV.
extension MainScreenVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // This function returns the number of items in the collection views.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == trendingPostsCollectionView {
            return trendingPosts.count
        } else {
            return topSubreddits.count
        }
    }

    // This function returns the filled cells for the collection views.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == trendingPostsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingPostCell", for: indexPath) as! TrendingPostCVC
            let post = trendingPosts[indexPath.row]
            
            cell.trendingPostLabel.text = post.title
            cell.trendingPostImage.image = nil // clear the image to avoid flickering
            cell.trendingPostImage.contentMode = .scaleAspectFill
            
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
                pickedIcons.removeAll()
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as! TrendingSubredditsCVC
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            
            // If the subreddit is in the favoriteSubreddits array, add a star symbol to the end of the subreddit name.
            if favoriteSubreddits.contains(subreddit) {
                cell.trendingSubredditLabel.text = subreddit + " ⭐️"
            } else {
                cell.trendingSubredditLabel.text = subreddit
            }
            
            // It keeps picking a random system image until it finds one that is not in the pickedIcons array.
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
    
    // This function returns the size of the cells in the collection views.
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
    
    // This function scrolls to next index when needed and starts a timer for auto-scrolling.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentIndex = trendingPostsCollectionView.contentOffset.x / trendingPostsCollectionView.bounds.size.width
        let nextIndex = round(currentIndex)
        
        let numberOfItemsInSection = trendingPostsCollectionView.numberOfItems(inSection: 0)
        guard nextIndex >= 0 && nextIndex < Double(numberOfItemsInSection) else {
            return
        }
        
        let indexPath = IndexPath(item: Int(nextIndex), section: 0)
        trendingPostsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        startScrollTimer()
    }
    
    // This function opens the selected post in the browser if it is a cell of the trendingPostsCollectionView
    // Or shows the posts screen of the selected subreddit if it is a cell of the trendingSubredditsCollectionView.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == trendingPostsCollectionView {
            let post = trendingPosts[indexPath.row]
            if post.permalink != ""{
                if let permalink = post.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "https://www.reddit.com/\(permalink)") {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            showPostsScreen(subredditToBeDisplayed: subreddit)
        }
    }
    
    // This function makes an auto-scrolling gesture.
    func startScrollTimer() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: freezeTime, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            
            let currentIndex = self.trendingPostsCollectionView.contentOffset.x / self.trendingPostsCollectionView.bounds.size.width
            var nextIndex = currentIndex
            
            if self.isScrollingBackwards {
                nextIndex -= 1
            } else {
                nextIndex += 1
            }
            
            if nextIndex >= CGFloat(self.trendingPosts.count) {
                nextIndex = CGFloat(self.trendingPosts.count - 2)
                self.isScrollingBackwards = true
            } else if nextIndex < 0 {
                nextIndex = 1
                self.isScrollingBackwards = false
            }
            
            let indexPath = IndexPath(item: Int(nextIndex), section: 0)
            self.trendingPostsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.startScrollTimer()
        })
    }


    // This function invalidates the scroll timer when the user starts dragging.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
}
