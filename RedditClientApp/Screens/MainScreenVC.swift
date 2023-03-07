//
//  MainScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit

class MainScreenVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var safeSearchSwitch: UISwitch!
    @IBOutlet weak var trendingPostsCollectionView: UICollectionView!
    @IBOutlet weak var trendingSubredditsCollectionView: UICollectionView!
    @IBOutlet weak var favoriteSubredditsTableView: UITableView!
    
    var redditAPI = RedditAPI()
    var topSubreddits: [String: Int] = [:]


    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "TrendingSubredditsCVC", bundle: nil)
        trendingSubredditsCollectionView.register(cellNib, forCellWithReuseIdentifier: "trendingSubredditCell")
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
        return topSubreddits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as! TrendingSubredditsCVC
        let subreddit = Array(topSubreddits.keys)[indexPath.row]
        cell.trendingSubredditLabel.text = subreddit
        
        // Get a random system image
        let systemImages = [
            "circle.grid.hex.fill","rectangle.stack.fill","triangle.fill","square.grid.3x1.below.line.grid.1x2.fill","rhombus.fill","hexagon.fill","pentagon.fill","octagon.fill","star.fill","sun.max.fill","moon.fill","cloud.fill","cloud.sun.fill","cloud.rain.fill","cloud.snow.fill","tornado",
            "hurricane","bolt.fill","umbrella.fill","flame.fill","drop.fill","waveform.path.ecg.rectangle.fill"]
        let randomIndex = Int.random(in: 0..<systemImages.count)
        let systemImage = UIImage(systemName: systemImages[randomIndex])
        cell.trendingSubredditImage.image = systemImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth = (collectionViewWidth - 20) / 3 // Subtract 20 for spacing between cells
        let cellHeight = collectionView.bounds.height / 2 // Divide height by 2 to create two rows
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

