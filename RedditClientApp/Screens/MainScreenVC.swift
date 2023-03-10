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
    @IBOutlet private weak var favoriteSubredditsTableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!

    var redditAPI = RedditAPI()

    // Defaults are used to store data locally on the device, there are two variables stored in defaults.
    let defaults = UserDefaults.standard
    var doesUserWantSafeSearch: Bool = false
    var favoriteSubreddits: [String] = []

    var topSubreddits: [String: Int] = [:]
    var trendingPosts: [RedditPost] = []
    var pickedIcons = [String]()

    // These variables are used to keep track of the timer for auto-scrolling feature of the trending posts.
    var isScrollingBackwards = false
    var freezeTime: TimeInterval = 4
    var scrollTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTrendingPosts()
        setupTrendingSubreddits()
        setupFavoriteSubreddits()

        // Load the variables from the device.
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }

        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        safeSearchSwitch.isOn = doesUserWantSafeSearch

        reloadFavoriteSubreddits()

        // Start the timer for the trending posts's auto-scrolling feature.
        startScrollTimer()
    }

    // This function handles all tasks related to the searchBar.
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
    }

    // This function handles all tasks related to the trendingPostsCV.
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

    // This function handles all tasks related to the trendingSubredditsCV.
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

    // This function handles all tasks related to the favoriteSubredditsTV.
    private func setupFavoriteSubreddits() {
        favoriteSubredditsTableView.dataSource = self
        favoriteSubredditsTableView.delegate = self
        favoriteSubredditsTableView.register(UINib(nibName: "FavoriteSubredditTVC", bundle: nil), forCellReuseIdentifier: "FavoriteSubredditCell")
    }

    private func reloadFavoriteSubreddits() {
        favoriteSubredditsTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(favoriteSubreddits.count) * favoriteSubredditsTableView.rowHeight
    }

    // This function shows the PostsScreenVC when a subreddit is selected.
    func showPostsScreen(subredditToBeDisplayed: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "postsScreen") as? PostsScreenVC {
                vc.subredditName = subredditToBeDisplayed
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
}
