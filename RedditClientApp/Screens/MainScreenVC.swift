//
//  MainScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit
import SDWebImage

class MainScreenVC: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var safeSearchSwitch: UISwitch!
    @IBOutlet private weak var trendingPostsCollectionView: UICollectionView!
    @IBOutlet private weak var trendingSubredditsCollectionView: UICollectionView!
    @IBOutlet private weak var favoriteSubredditsTableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var redditAPI = RedditAPI()
    
    let defaults = UserDefaults.standard
    var doesUserWantSafeSearch: Bool = false
    var favoriteSubreddits: [String] = []
    
    var topSubreddits: [String: Int] = [:]
    var trendingPosts: [RedditPost] = []
    var pickedIcons = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFavoriteSubreddits()
        setupTrendingPosts()
        setupTrendingSubreddits()
        
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }
        
        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        safeSearchSwitch.isOn = doesUserWantSafeSearch
        
        reloadFavoriteSubreddits()
        
    }
    private func setupFavoriteSubreddits(){
        favoriteSubredditsTableView.dataSource = self
        favoriteSubredditsTableView.delegate = self
        favoriteSubredditsTableView.register(UINib(nibName: "FavoriteSubredditTVC", bundle: nil), forCellReuseIdentifier: "FavoriteSubredditCell")
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
    
    private func reloadFavoriteSubreddits() {
        favoriteSubredditsTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(favoriteSubreddits.count) * favoriteSubredditsTableView.rowHeight
    }
    
    private func showPostsScreen(subredditToBeDisplayed: String){
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "postsScreen") as! PostsScreen
            
            vc.subredditName = subredditToBeDisplayed
            
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
}


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



extension MainScreenVC {
    @IBAction func safeSearchSwitchValueChanged(_ sender: UISwitch) {
        doesUserWantSafeSearch = safeSearchSwitch.isOn
        defaults.set(doesUserWantSafeSearch, forKey: "safeSearch")
        defaults.synchronize()
        
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
extension MainScreenVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSubreddits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteSubredditCell", for: indexPath) as! FavoriteSubredditTVC
        cell.favoriteSubredditLabel.text = "r/" + favoriteSubreddits[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: favoriteSubreddits[indexPath.row])
    }

    
}
