//
//  MainScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit
import SDWebImage

class MainScreenVC: UIViewController{
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
        
        trendingPostsCollectionView.dataSource = self
        trendingPostsCollectionView.delegate = self
        //Trending posts collection view
        trendingPostsCollectionView.register(UINib(nibName: "TrendingPostCVC", bundle: nil), forCellWithReuseIdentifier: "trendingPostCell")
        // Call the API to get the Reddit posts
        redditAPI.getRedditPostsFromSubreddit(subredditName: "funny", safeSearch: safeSearchSwitch.isOn, onlyPostsWithImages: true) { (posts, error) in
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

        //Trending subreddits collection view
        let trendingSubredditCellNib = UINib(nibName: "TrendingSubredditsCVC", bundle: nil)
        trendingSubredditsCollectionView.register(trendingSubredditCellNib, forCellWithReuseIdentifier: "trendingSubredditCell")
        trendingSubredditsCollectionView.dataSource = self
        trendingSubredditsCollectionView.delegate = self
        redditAPI.getTopSubredditsFromPopularPosts { [weak self] (subreddits, error) in
            if let subreddits = subreddits {
                self?.topSubreddits = subreddits
                self?.trendingSubredditsCollectionView.reloadData()
            } else if let error = error {
                print("Error getting top subreddits: \(error)")
            }
        }
        // Do any additional setup after loading the view.
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as! TrendingSubredditsCVC
            let subreddit = Array(topSubreddits.keys)[indexPath.row]
            cell.trendingSubredditLabel.text = subreddit
            
            // Get a random system image
            let systemImages = [
                "circle.grid.hex", "rectangle.stack", "triangle","square.grid.3x1.below.line.grid.1x2", "rhombus","hexagon", "pentagon", "octagon", "star", "sun.max", "moon", "cloud", "cloud.sun", "cloud.rain", "cloud.snow", "tornado", "hurricane", "bolt", "umbrella", "flame", "drop", "waveform.path.ecg.rectangle"]
            let randomIndex = Int.random(in: 0..<systemImages.count)
            let systemImage = UIImage(systemName: systemImages[randomIndex])
            cell.trendingSubredditImage.image = systemImage
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == trendingPostsCollectionView {
            let collectionViewWidth = collectionView.bounds.width
            let collectionViewHeight = collectionView.bounds.height
            return CGSize(width: collectionViewWidth, height: collectionViewHeight)
        } else {
            let collectionViewWidth = collectionView.bounds.width
            let cellWidth = (collectionViewWidth - 20) / 3
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
}
    
    
    
    extension MainScreenVC {
        @IBAction func safeSearchSwitchValueChanged(_ sender: UISwitch) {
            // Call the API again with the updated safe search option
            redditAPI.getRedditPostsFromSubreddit(subredditName: "funny", safeSearch: sender.isOn, onlyPostsWithImages: true) { (posts, error) in
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
