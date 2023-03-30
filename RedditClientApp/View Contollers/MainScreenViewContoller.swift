//
//  MainScreenViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import UIKit
import SideMenu
import Lottie

final class MainScreenViewContoller: BaseViewController {
    @IBOutlet private weak var sideMenuButton: UIButton!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var trendingPostsCollectionView: UICollectionView!
    @IBOutlet private weak var trendingSubredditsCollectionView: UICollectionView!
    @IBOutlet private weak var favoriteSubredditsTableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    private var menu = SideMenuNavigationController(rootViewController: SideMenuViewContoller())

    // Defaults are used to store data locally on the device, there are two variables stored in defaults.
    private let defaults = UserDefaults.standard
    private var doesUserWantSafeSearch: Bool = false
    private var doesUserWantPostsWithImagesOnly = false
    private var favoriteSubreddits: [String] = []

    // Variables below are used to strore the data retrieved from the API calls.
    private var topSubreddits: [String: Int] = [:]
    private var trendingPosts: [RedditPostData] = []

    private var pickedIcons = [String]()
    private let iconsToBePicked = ["circle", "rectangle", "triangle", "square", "rhombus", "hexagon", "pentagon", "octagon", "star", "sun.max", "moon", "cloud", "cloud.sun", "cloud.rain", "cloud.snow", "tornado", "hurricane", "bolt", "umbrella", "flame", "drop", "waveform.path.ecg.rectangle"]

    // These variables are used to keep track of the timer for auto-scrolling feature of the trending posts.
    private var isScrollingBackwards = false
    private var freezeTime: TimeInterval = 2
    private var scrollTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSideMenu()
        setupSearchBar()

        setupTrendingPostsCollectionView()
        makeAPICallForTrendingPostsCollectionView()

        setupTrendingSubredditsCollectionView()
        makeAPICallForTrendingSubredditsCollectionView()

        setupFavoriteSubredditsTableView()

        reloadFavoriteSubreddits()

        doesUserWantSafeSearch = defaults.bool(forKey: UserDefaultsKeys.safeSearch)
        doesUserWantPostsWithImagesOnly = defaults.bool(forKey: UserDefaultsKeys.postsWithImages)
    }

    // This function is triggered when the view is about to appear, and it is used to start the timer for the trending posts's auto-scrolling feature.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScrollTimer()
        reloadFavoriteSubreddits()
        trendingSubredditsCollectionView.reloadData()
    }

    // This function is triggered when the view is about to disappear, and it is used to invalidate the timer for the trending posts's auto-scrolling feature.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollTimer?.invalidate()
        scrollTimer = nil
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
    func setupTrendingPostsCollectionView() {
        trendingPostsCollectionView.dataSource = self
        trendingPostsCollectionView.delegate = self
        trendingPostsCollectionView.register(UINib(nibName: "TrendingPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "trendingPostCell")
    }

    // This function is used to make the API call for the trending posts.
    private func makeAPICallForTrendingPostsCollectionView() {
        let (animationView, overlayView) = displayRedditLogoAnimation()
        fetchRedditPosts(subredditName: "popular", safeSearch: doesUserWantSafeSearch, onlyPostsWithImages: true) { result in
            switch result {
            case .success(let redditPosts):
                self.trendingPosts = redditPosts
                DispatchQueue.main.async {
                    self.trendingPostsCollectionView.reloadData()
                    self.hideRedditLogoAnimation(animation: (animationView, overlayView))
                }
            case .failure(let error):
                print("Error fetching Reddit posts:", error.localizedDescription)
            }
        }
    }

    // This function handles all tasks related to the trendingSubredditsCV.
    private func setupTrendingSubredditsCollectionView() {
        trendingSubredditsCollectionView.dataSource = self
        trendingSubredditsCollectionView.delegate = self
        trendingSubredditsCollectionView.register(UINib(nibName: "TrendingSubredditsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "trendingSubredditCell")
    }

    // This function is used to make the API call for the trending subreddits.
    private func makeAPICallForTrendingSubredditsCollectionView() {

        let (animationView, overlayView) = displayRedditLogoAnimation()

        NetworkManager.shared.getTopSubredditsFromPopularPosts { [weak self] (subreddits, error) in
            guard let self = self else { return }

            if let subreddits = subreddits {
                self.topSubreddits = subreddits
                self.trendingSubredditsCollectionView.reloadData()
                self.hideRedditLogoAnimation(animation: (animationView, overlayView))
            } else if let error = error {
                self.displayAlertMessage(message: "Error getting top subreddits: \(error)")
            }
        }
    }

    // This function handles all tasks related to the favoriteSubredditsTV.
    private func setupFavoriteSubredditsTableView() {
        favoriteSubredditsTableView.dataSource = self
        favoriteSubredditsTableView.delegate = self
        favoriteSubredditsTableView.register(UINib(nibName: "FavoriteSubredditTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteSubredditCell")
    }

    // This function is used to reload the favoriteSubredditsTV after the user adds or removes a subreddit from the favorites.
    private func reloadFavoriteSubreddits() {
        if let savedSubreddits = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.favoriteSubreddits) {
            favoriteSubreddits = savedSubreddits
        }
        favoriteSubredditsTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(favoriteSubreddits.count) * favoriteSubredditsTableView.rowHeight
    }
}

// This extension is used to handle the search bar in the MainScreenViewContoller.
extension MainScreenViewContoller: UISearchBarDelegate {
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
extension MainScreenViewContoller: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingPostCell", for: indexPath) as? TrendingPostCollectionViewCell else {
                self.displayAlertMessage(message: "Unable to dequeue TrendingPostCollectionViewCell")
                return UICollectionViewCell()
            }
            let post = trendingPosts[indexPath.row]
            cell.configureCell(title: post.title, imageURLToBeSet: post.imageURL)
            return cell
        } else {
            if pickedIcons.count >= iconsToBePicked.count {
                pickedIcons.removeAll()
            }

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingSubredditCell", for: indexPath) as? TrendingSubredditsCollectionViewCell else {
                self.displayAlertMessage(message: "Unable to dequeue TrendingSubredditsCollectionViewCell")
                return UICollectionViewCell()
            }

            let subreddit = Array(topSubreddits.keys)[indexPath.row]

            // If the subreddit is in the favoriteSubreddits array, add a star symbol to the beginning of the subreddit name.
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
                displayRedditPost(postToBeDisplayed: post)
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
        
        DispatchQueue.main.async {
            self.trendingPostsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        startScrollTimer()
    }

    // This function makes an auto-scrolling gesture.
    // After reaching the end of the collection view, it starts scrolling backwards.
    func startScrollTimer() {
        scrollTimer = Timer.scheduledTimer(withTimeInterval: freezeTime, repeats: true, block: { [weak self] _ in
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
            DispatchQueue.main.async {
                self.trendingPostsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        })
    }

    // This function invalidates the scroll timer when the user starts dragging.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
}

// This extension is used to handle the favoriteSubredditsTableView in the MainScreenViewContoller.
extension MainScreenViewContoller: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteSubreddits.count
    }

    // This function is used to display the favorite subreddits in the favoriteSubredditsTableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteSubredditCell", for: indexPath) as? FavoriteSubredditTableViewCell else {
            self.displayAlertMessage(message: "Unable to dequeue FavoriteSubredditCell")
            return UITableViewCell()
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

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completion) in
            let deletedSubreddit = self.favoriteSubreddits[indexPath.row]
            self.favoriteSubreddits.remove(at: indexPath.row)
            self.defaults.set(self.favoriteSubreddits, forKey: UserDefaultsKeys.favoriteSubreddits)

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
