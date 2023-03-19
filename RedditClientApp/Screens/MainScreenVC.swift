//
//  MainScreenVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit
import SDWebImage
import SideMenu

final class MainScreenVC: UIViewController {
    @IBOutlet private weak var sideMenuButton: UIButton!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var trendingPostsCollectionView: UICollectionView!
    @IBOutlet private weak var trendingSubredditsCollectionView: UICollectionView!
    @IBOutlet private weak var favoriteSubredditsTableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    private var menu = SideMenuNavigationController(rootViewController: SideMenuVC())

    private var networkManager = NetworkManager()

    // Defaults are used to store data locally on the device, there are two variables stored in defaults.
    private let defaults = UserDefaults.standard
    private var doesUserWantSafeSearch: Bool = false
    private var doesUserWantPostsWithImagesOnly = false
    private var favoriteSubreddits: [String] = []

    private var topSubreddits: [String: Int] = [:]
    private var trendingPosts: [RedditPostData] = []
    
    private var pickedIcons = [String]()
    private let iconsToBePicked = ["circle.grid.hex","rectangle.stack","triangle",
                        "square.grid.3x1.below.line.grid.1x2","rhombus","hexagon",
                        "pentagon", "octagon", "star", "sun.max", "moon", "cloud",
                        "cloud.sun", "cloud.rain", "cloud.snow", "tornado",
                        "hurricane", "bolt", "umbrella", "flame",
                        "drop", "waveform.path.ecg.rectangle"]

    // These variables are used to keep track of the timer for auto-scrolling feature of the trending posts.
    private var isScrollingBackwards = false
    private var freezeTime: TimeInterval = 2
    private var scrollTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        setupSearchBar()
        setupTrendingPosts()
        setupTrendingSubreddits()
        setupFavoriteSubreddits()

        // Load the variables from the device.
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: "favoriteSubreddits") {
            favoriteSubreddits = savedSubreddits
        }

        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        doesUserWantPostsWithImagesOnly = defaults.bool(forKey: "postsWithImages")
        
        reloadFavoriteSubreddits()

        // Start the timer for the trending posts's auto-scrolling feature.
        startScrollTimer()
    }

    @IBAction private func sideMenuButtonTapped(_ sender: Any) {
        present(menu, animated: true)
    }
    
    // This function is used to set the side menu.
    private func setupSideMenu() {
        menu.leftSide = true
        menu.setNavigationBarHidden(true, animated: false)
        sideMenuButton.tintColor = .black
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
        trendingPostsCollectionView.register(UINib(nibName: "TrendingPostCollectionViewCell",bundle: nil),forCellWithReuseIdentifier: "trendingPostCell")

        networkManager.getRedditPostsFromSubreddit(subredditName: "popular", safeSearch: doesUserWantSafeSearch, onlyPostsWithImages: true) { [weak self] (posts, error) in
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
        trendingSubredditsCollectionView.register(UINib(nibName: "TrendingSubredditsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "trendingSubredditCell")

        networkManager.getTopSubredditsFromPopularPosts { [weak self] (subreddits, error) in
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
        favoriteSubredditsTableView.register(UINib(nibName: "FavoriteSubredditTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteSubredditCell")
    }

    private func reloadFavoriteSubreddits() {
        favoriteSubredditsTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(favoriteSubreddits.count) * favoriteSubredditsTableView.rowHeight
    }

    // This function shows the PostsScreenVC when a subreddit is selected.
    private func showPostsScreen(subredditToBeDisplayed: String) {
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

// This extension is used to handle the search bar in the MainScreenVC.
extension MainScreenVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Remove trimming characters.
        guard var subreddit = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !subreddit.isEmpty else {
            return
        }
        // Capitalize each word except the first one for camel casing.
        subreddit = subreddit.components(separatedBy: .whitespaces).enumerated().map { (index, word) in
            return index == 0 ? word : word.capitalized
        }.joined()
        showPostsScreen(subredditToBeDisplayed: subreddit)
    }
}


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
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
        if collectionView == trendingPostsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingPostCell", for: indexPath) as? TrendingPostCollectionViewCell else {
                fatalError("Unable to dequeue TrendingPostCollectionViewCell")
            }
            let post = trendingPosts[indexPath.row]

            cell.configureCell(title: post.title, image: nil)

            guard let imageURL = URL(string: post.imageURL) else {
                return cell // Return a valid cell in case of a URL issue
            }

            networkManager.getPostImage(from: imageURL) { (image, error) in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.configureCell(title: post.title, image: image)
                    }
                } else if let error = error {
                    print("Error loading post image: \(error.localizedDescription)")
                }
            }
            return cell
        }
        else {
            // Removes the whole array if it is full to avoid a crash.
            if pickedIcons.count >= iconsToBePicked.count {
                pickedIcons.removeAll()
            }

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as? TrendingSubredditsCollectionViewCell else {
                fatalError("Unable to dequeue TrendingSubredditsCollectionViewCell")
            }

            let subreddit = Array(topSubreddits.keys)[indexPath.row]

            // If the subreddit is in the favoriteSubreddits array, add a star symbol to the end of the subreddit name.
            if favoriteSubreddits.contains(subreddit) {
                cell.configureCell(title: "⭐️ " + subreddit, image: nil)
            } else {
                cell.configureCell(title: subreddit, image: nil)
            }

            // It keeps picking a random system image until it finds one that is not in the pickedIcons array.
            var systemImage: UIImage?
            repeat {
                let randomIndex = Int.random(in: 0..<iconsToBePicked.count)
                let iconName = iconsToBePicked[randomIndex]
                if !pickedIcons.contains(iconName) {
                    pickedIcons.append(iconName)
                    systemImage = UIImage(systemName: iconName)
                    break
                }
            } while systemImage == nil

            cell.configureCell(title: cell.getSubredditLabel() ?? "", image: systemImage)

            return cell
        }
    }


    // This function returns the size of the cells in the collection views.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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

    // This function makes an auto-scrolling gesture.
    // After reaching the end of the collection view, it starts scrolling backwards.
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


// This extension is used to handle the favoriteSubredditsTableView in the MainScreenVC.
extension MainScreenVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSubreddits.count
    }

    // This function is used to display the favorite subreddits in the favoriteSubredditsTableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteSubredditCell", for: indexPath) as? FavoriteSubredditTableViewCell else {
            fatalError("Unable to dequeue FavoriteSubredditCell")
        }

        let subreddit = "r/" + favoriteSubreddits[indexPath.row]
        cell.configureCell(subreddit: subreddit)

        return cell
    }

    // This function calls the showPostsScreen function when a favorite subreddit is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: favoriteSubreddits[indexPath.row])
    }

    // This function is used to delete a favorite subreddit from the favoriteSubredditsTableView with a swipe gesture.
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (action, view, completion) in
            let deletedSubreddit = self.favoriteSubreddits[indexPath.row]
            self.favoriteSubreddits.remove(at: indexPath.row)
            self.defaults.set(self.favoriteSubreddits, forKey: "favoriteSubreddits")
            self.defaults.synchronize()

            tableView.deleteRows(at: [indexPath], with: .automatic)

            // Reload the cell if it exists in trendingSubreddits array
            if self.topSubreddits.keys.contains(deletedSubreddit) {
                let index = Array(self.topSubreddits.keys).firstIndex(of: deletedSubreddit)!
                let indexPath = IndexPath(item: index, section: 0)
                self.trendingSubredditsCollectionView.reloadItems(at: [indexPath])
            }
            completion(true)
        }

        deleteAction.image = UIImage(systemName: "trash")

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }
}
