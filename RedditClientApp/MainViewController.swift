//
//  ViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.02.2023.
//

import UIKit


class MainViewController: UIViewController{
    var subreddit = ""
    
    var redditPosts : [RedditPost] = []
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

      enum CodingKeys: String, CodingKey {
        case thumbnail
        case title
        case selftext
      }

      func toRedditPost() -> RedditPost {
        return RedditPost(imageURL: thumbnail, title: title, description: selftext)
      }
    }
    
    @IBOutlet weak var searchBar: UITextField!
    
      @IBAction func searchButtonPressed(_ sender: Any) {
        subreddit = searchBar.text!
        if subreddit != "" {
            searchBar.text = ""
            makeRedditAPICall(subreddit: subreddit, maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
            showPostsScreen()
        }
    }

    @IBAction func trendingsButton(_ sender: Any) {
        makeRedditAPICall(subreddit: "trendingsubreddits", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "trendings"
    }

    @IBAction func technologyButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "technology", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "technology"
    }

    @IBAction func photographyButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "photography", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "photography"
    }

    @IBAction func scienceButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "science", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "science"
    }

    @IBAction func computersButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "computers", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "computers"
    }

    @IBAction func newsButtonPressed(_ sender: Any) {
        makeRedditAPICall(subreddit: "news", maximumNumberOfPosts: 50, willItBeUsedForViewController: false)
        subreddit = "news"
    }

    //This function is used to show the posts screen
    @IBAction func showPostsScreen(){
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "postsScreen") as! PostsScreen
            vc.postsArray = self.redditPosts
            vc.subredditName = self.subreddit
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
    @IBOutlet private weak var trendingsCollectionView: UICollectionView!
    
    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    let reuseIdentifier = "CarouselCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRedditAPICall(subreddit: "turkey", maximumNumberOfPosts: 50, willItBeUsedForViewController: true)
        trendingsCollectionView.dataSource = self
        trendingsCollectionView.delegate = self
        trendingsCollectionView.register(TrendingCarouselCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.hideKeyboardWhenTappedAround()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "toPostsScreen" {
        let destinationVC = segue.destination as! PostsScreen
          destinationVC.postsArray = redditPosts
          destinationVC.subredditName = subreddit
      }
    }

    //This function is used to make the API call and put the data into redditPosts array
    func makeRedditAPICall(subreddit: String, maximumNumberOfPosts: Int, willItBeUsedForViewController: Bool) {
      let url = URL(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(maximumNumberOfPosts)")!
      let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
          let decoder = JSONDecoder()
          do {
            let redditResponse = try decoder.decode(RedditResponse.self, from: data)
              if(willItBeUsedForViewController){
                  self.trengingPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
              }else{
                  self.redditPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
                  self.showPostsScreen()
              }
              print(self.redditPosts)
          } catch {
              print("Error decoding JSON: \(error.localizedDescription)")
          }
        }
      }
      task.resume()
    }
}

//MARK: - Extension below contains functions related to the collection view that displays the trending posts.
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trengingPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrendingCarouselCell
        
        let data = trengingPosts[indexPath.row]
        let imageURL = URL(string: data.imageURL)
        let imageView = cell.imageView
        
        cell.textLabel.text = data.title
        
        DispatchQueue.global().async {
            if let url = imageURL, let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        //if let imageView = imageView {
                            imageView.image = image
                        //}
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        let height = collectionView.frame.size.height
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Calculate the index of the next item
        let currentIndex = trendingsCollectionView.contentOffset.x / trendingsCollectionView.bounds.size.width
        let nextIndex = round(currentIndex)

        // Scroll to the next item with animation
        let indexPath = IndexPath(item: Int(nextIndex), section: 0)
        trendingsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        //Make a short vibration when fully scrolled
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
    }
}

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


