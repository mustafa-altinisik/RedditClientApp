//
//  MainScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit
import SDWebImage

class MainScreenVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var safeSearchSwitch: UISwitch!
    @IBOutlet weak var trendingPostsCollectionView: UICollectionView!
    @IBOutlet weak var trendingSubredditsCollectionView: UICollectionView!
    @IBOutlet weak var favoriteSubredditsTableView: UITableView!
    
    @IBOutlet weak var tableviewHeightConstraint: NSLayoutConstraint!
    var redditAPI = RedditAPI()
    var topSubreddits: [String: Int] = [:]
    var trendingPosts: [RedditPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrendingPosts()
        setupTrendingSubreddits()
    }
    
    private func setupTrendingPosts() {
        trendingPostsCollectionView.dataSource = self
        trendingPostsCollectionView.delegate = self
        trendingPostsCollectionView.register(UINib(nibName: "TrendingPostCVC",bundle: nil),forCellWithReuseIdentifier: "trendingPostCell")
        
        redditAPI.getRedditPostsFromSubreddit(subredditName: "popular", safeSearch: safeSearchSwitch.isOn, onlyPostsWithImages: true) { [weak self] (posts, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error retrieving Reddit posts: \(error.localizedDescription)")
                return
            }
            guard let posts = posts else {
                print("No posts retrieved")
                return
            }
            self.trendingPosts = posts
            DispatchQueue.main.async {
                self.trendingPostsCollectionView.reloadData()
            }
        }
    }
    private func setupTrendingSubreddits() {
        trendingSubredditsCollectionView.dataSource = self
        trendingSubredditsCollectionView.delegate = self
        trendingSubredditsCollectionView.register(UINib(nibName: "TrendingSubredditsCVC", bundle: nil), forCellWithReuseIdentifier: "trendingSubredditCell")
        
        redditAPI.getTopSubredditsFromPopularPosts { [weak self] (subreddits, error) in
            guard let self = self else { return }
            
            if let subreddits = subreddits {
                self.topSubreddits = subreddits
                self.trendingSubredditsCollectionView.reloadData()
            } else if let error = error {
                print("Error getting top subreddits: \(error)")
            }
        }
    }
}


extension MainScreenVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as! TrendingSubredditsCVC
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            cell.trendingSubredditLabel.text = subreddit
            
            // Get a random system image
            let systemImages = [
                "circle.grid.hex", "rectangle.stack","triangle","square.grid.3x1.below.line.grid.1x2", "rhombus","hexagon", "pentagon", "octagon", "star", "sun.max", "moon", "cloud", "cloud.sun", "cloud.rain", "cloud.snow", "tornado", "hurricane", "bolt", "umbrella", "flame", "drop", "waveform.path.ecg.rectangle"]
            let randomIndex = Int.random(in: 0..<systemImages.count)
            let systemImage = UIImage(systemName: systemImages[randomIndex])
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == trendingPostsCollectionView {
            return 10
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == trendingPostsCollectionView {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
}



extension MainScreenVC {
    @IBAction func safeSearchSwitchValueChanged(_ sender: UISwitch) {
        // Call the API again with the updated safe search option
        redditAPI.getRedditPostsFromSubreddit(subredditName: "popular", safeSearch: sender.isOn, onlyPostsWithImages: true) { (posts, error) in
            if let error = error {
                print("Error retrieving Reddit posts: \(error.localizedDescription)")
                return
            }
            
            guard let posts = posts else {
                print("No posts retrieved")
                return
            }
            
            // Update the data source with the retrieved posts
            self.trendingPosts = posts
            
            // Reload the collection view to display the new data
            DispatchQueue.main.async {
                self.trendingPostsCollectionView.reloadData()
            }
        }
    }
}
