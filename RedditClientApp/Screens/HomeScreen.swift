//
//  ViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.02.2023.
//

import UIKit


class HomeScreen: UIViewController{
    
    @IBOutlet private weak var trendingsCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var safeSearchSwitch: UISwitch!
    
    var subreddit = ""
    
    //This is the subreddit that will be displayed on the trending posts carousel in the main screen
    var subredditToBeDisplayedOnTrendingPostsViewCell = "turkey"
    
    //This array is used to store the posts that will be displayed on the posts screen
    var redditPosts : [RedditPost] = []

    //This array is used to store the posts that will be displayed on the trending posts carousel in the main screen
    var trendingPosts : [RedditPost] = []


    //doesUserWantSafeSearch is used to determine if the user wants to see the safe search posts or not, it is stored in the user defaults
    let defaults = UserDefaults.standard
    var doesUserWantSafeSearch: Bool = false
    var hasSafeSearchValueChanged = false


    struct RedditResponse: Codable {
      let data: RedditData
    }

    struct RedditData: Codable {
      let children: [RedditChild]
    }

    struct RedditChild: Codable {
      let data: RedditPostData
    }

    struct RedditPostData: Codable {
      let thumbnail: String
      let title: String
      let selftext: String
      let permalink: String
      let over_18: Bool
        
    enum CodingKeys: String, CodingKey {
        case thumbnail
        case title
        case selftext
        case permalink
        case over_18
      }

      //This function is used to convert the data from the API call to RedditPost struct
      func toRedditPost() -> RedditPost {
          return RedditPost(imageURL: thumbnail, title: title, description: selftext, permalink: permalink, over_18: over_18)
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doesUserWantSafeSearch = defaults.bool(forKey: "safeSearch")
        safeSearchSwitch.isOn = doesUserWantSafeSearch
        makeRedditAPICall(subreddit: subredditToBeDisplayedOnTrendingPostsViewCell, maximumNumberOfPosts: 10, willItBeUsedForCarousel: true)
        trendingsCollectionView.dataSource = self
        trendingsCollectionView.delegate = self
        trendingsCollectionView.register(TrendingCarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        self.hideKeyboardWhenTappedAround()
    }
    
    //This function is triggered when the user changes the safe search switch, it saves the value to the user defaults and refreshes the trending posts carousel.
    @IBAction func safeSearchValueHasChanged(_ sender: Any) {
        doesUserWantSafeSearch = safeSearchSwitch.isOn
        defaults.set(doesUserWantSafeSearch, forKey: "safeSearch")
        defaults.synchronize()
        hasSafeSearchValueChanged = true
        trendingsCollectionView.reloadData()
    }
    
//MARK: - IBActions below are used to make the API call and display the posts page when the user presses one of the buttons.
    @IBAction func searchButtonPressed(_ sender: Any) {
        subreddit = searchBar.text!
        if subreddit != "" {
            searchBar.text = ""
            makeRedditAPICall(subreddit: subreddit, maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        }
    }

    @IBAction func trendingsButton(_ sender: Any) {
        makeRedditAPICall(subreddit: "trendingsubreddits", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "trendings"
    }

    @IBAction func technologyButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "technology", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "technology"
    }

    @IBAction func photographyButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "photography", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "photography"
    }

    @IBAction func scienceButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "science", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "science"
    }

    @IBAction func computersButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "computers", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "computers"
    }

    @IBAction func newsButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "news", maximumNumberOfPosts: 50, willItBeUsedForCarousel: false)
        subreddit = "news"
    }

    //This function is used to show the posts screen
    func showPostsScreen(){
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "postsScreen") as! PostsScreen
            if(self.doesUserWantSafeSearch){
                self.redditPosts = self.filterSafePosts(posts: self.redditPosts)
            }
            vc.postsArray = self.redditPosts
            vc.subredditName = self.subreddit
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
//MARK: -Other functions.
    //This function is used to make the API call and put the data into redditPosts array
    //subreddit is the subreddit that the user wants to see the posts from
    //maximumNumberOfPosts is the maximum number of posts that will be displayed
    //willItBeUsedForCarousel is a boolean value that is used to determine if the data will be used for the posts screen or the trending posts carousel
    func makeRedditAPICall(subreddit: String, maximumNumberOfPosts: Int, willItBeUsedForCarousel: Bool) {
      let url = URL(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(maximumNumberOfPosts)")!
      //URL session is used to make the API call
      let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
          let decoder = JSONDecoder()
          do {
            let redditResponse = try decoder.decode(RedditResponse.self, from: data)
              //If the data will be used for the trending posts carousel, the data will be put into the trengingPosts array and reddit posts screen will not be shown.
              if(willItBeUsedForCarousel){
                    self.trendingPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
              }else{
                  //If the data will be used for the posts screen, the data will be put into the redditPosts array and the posts screen will be shown.
                  self.redditPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
                  self.showPostsScreen()
              }
          } catch {
            //If there is an error, it will be printed to the console.
            print("Error decoding JSON: \(error.localizedDescription)")
          }
        }
      }
      //The task is resumed to start the API call.
      task.resume()
    }
    
    //This function is used to filter the posts that are flagged as over 18.
    func filterSafePosts(posts: [RedditPost]) -> [RedditPost] {
        var safePosts : [RedditPost] = []
        for post in posts {
            if post.over_18 == false {
                safePosts.append(post)
            }else{
                var updatedPost = post
                updatedPost.title = "Not Safe"
                updatedPost.description = "Please change your search preferences to see."
                updatedPost.imageURL = "https://github.com/mustafa-altinisik/RedditClientApp/blob/main/RedditClientApp/Assets.xcassets/over_18.imageset/over_18.jpeg"
                updatedPost.permalink = ""
                safePosts.append(updatedPost)
            }
        }
        return safePosts
    }
}

//MARK: - Extension below contains functions related to the collection view that displays the trending posts.
extension HomeScreen: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    
    //This function is used to determine the number of items in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trendingPosts.count
    }
    
    //This function is used to determine the content of each cell in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! TrendingCarouselCell
        
        //If the safe search value has changed, the trending posts will be updated.
        if(hasSafeSearchValueChanged){
            makeRedditAPICall(subreddit: subredditToBeDisplayedOnTrendingPostsViewCell, maximumNumberOfPosts: 10, willItBeUsedForCarousel: true)
        }
        
        //If the user wants safe search, the trending posts will be filtered.
        if(doesUserWantSafeSearch){
            trendingPosts = filterSafePosts(posts: trendingPosts)
        }
        
        let data = trendingPosts[indexPath.row]
                    
        let imageURL = URL(string: data.imageURL)
        let imageView = cell.imageView
            
        cell.textLabel.text = data.title
            
        //The image is downloaded in the background and then displayed in the main thread.
        DispatchQueue.global().async {
            if let url = imageURL, let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
        return cell
    }
    
    //This function is used to determine the size of each cell in the collection view, makes the cells the same size as the collection view.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    //This function is used to make a one by one scrolling effect in the collection view and olso to prevent the user from scrolling when there are no more posts to scroll to.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Calculate the index of the next item
        let currentIndex = trendingsCollectionView.contentOffset.x / trendingsCollectionView.bounds.size.width
        let nextIndex = round(currentIndex)

        // Check if the next index is within the range of the number of items in the section
        let numberOfItemsInSection = trendingsCollectionView.numberOfItems(inSection: 0)
        guard nextIndex >= 0 && nextIndex < Double(numberOfItemsInSection) else {
            return
        }

        // Scroll to the next item with animation
        let indexPath = IndexPath(item: Int(nextIndex), section: 0)
        trendingsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        //Make a short vibration when fully scrolled
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    //This function opens the post on the reddit website when the user taps on a post in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = trendingPosts[indexPath.row]
        if post.permalink != ""{
            if let permalink = post.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.reddit.com/\(permalink)") {
                UIApplication.shared.open(url)
            }
        }
    }
}

//MARK: - Extension below contains functions that are used to hide the keyboard when the user taps outside of the text field.
extension HomeScreen {
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(
      target: self, action: #selector(HomeScreen.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}


