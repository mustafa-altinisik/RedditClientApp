//
//  ViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.02.2023.
//

import UIKit


class MainViewController: UIViewController{
    
    @IBOutlet private weak var trendingsCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UITextField!
    
    var subreddit = ""
    //This array is used to store the posts that will be displayed on the posts screen
    var redditPosts : [RedditPost] = []
    //This array is used to store the posts that will be displayed on the trending posts carousel in the main screen
    var trengingPosts : [RedditPost] = []

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
        
    enum CodingKeys: String, CodingKey {
        case thumbnail
        case title
        case selftext
        case permalink
      }

      //This function is used to convert the data from the API call to RedditPost struct
      func toRedditPost() -> RedditPost {
        return RedditPost(imageURL: thumbnail, title: title, description: selftext, permalink: permalink)
      }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRedditAPICall(subreddit: "turkey", maximumNumberOfPosts: 10, willItBeUsedForCarousel: true)
        trendingsCollectionView.dataSource = self
        trendingsCollectionView.delegate = self
        trendingsCollectionView.register(TrendingCarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        self.hideKeyboardWhenTappedAround()
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
            vc.postsArray = self.redditPosts
            vc.subredditName = self.subreddit
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
//MARK: -Other functions.
    
    //This function is used to pass the data to the posts screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "toPostsScreen" {
        let destinationVC = segue.destination as! PostsScreen
          destinationVC.postsArray = redditPosts
          destinationVC.subredditName = subreddit
      }
    }

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
                  self.trengingPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
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
}

//MARK: - Extension below contains functions related to the collection view that displays the trending posts.
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //This function is used to determine the number of items in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trengingPosts.count
    }
    
    //This function is used to determine the content of each cell in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! TrendingCarouselCell
        //Data is the data that will be put into the cell.
        let data = trengingPosts[indexPath.row]
        
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
}

//MARK: - Extension below contains functions that are used to hide the keyboard when the user taps outside of the text field.
extension MainViewController {
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(
      target: self, action: #selector(MainViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}


