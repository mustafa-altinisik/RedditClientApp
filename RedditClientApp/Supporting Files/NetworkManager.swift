//
//  Network Manager.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 4.03.2023.
//

import Foundation
import Alamofire
import Lottie

class NetworkManager {
    
    //Singleton pattern is applied by adding the variable below.
    static let shared = NetworkManager()
    private init() {}

    // This function is used to get the posts from a subreddit.
    func getRedditPostsFromSubreddit(subredditName: String, completion: @escaping (Result<RedditResponse, Error>) -> Void) {
        let url = "https://www.reddit.com/r/\(subredditName)/.json"
        AF.request(url)
            .validate()
            .responseDecodable(of: RedditResponse.self) { response in
                switch response.result {
                case .success(let redditResponse):
                    completion(.success(redditResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // This function gets all popular posts from reddit and returns the top 6 subreddits.
    // I've implemented this function becasuse Reddit API doesn't have a way to get the top subreddits.
    func getTopSubredditsFromPopularPosts(completion: @escaping ([String: Int]?, Error?) -> Void) {
        let url = "https://www.reddit.com/r/all/new.json"
        AF.request(url)
            .validate()
            .responseDecodable(of: RedditResponse.self) { response in
                switch response.result {
                case .success(let redditResponse):
                    let posts = redditResponse.data.children.map { $0.data }
                    var subredditCounts: [String: Int] = [:]
                    for post in posts where post.subreddit != nil {
                        if let subreddit = post.subreddit {
                            subredditCounts[subreddit] = (subredditCounts[subreddit] ?? 0) + 1
                        }
                    }
                    let sortedSubreddits = subredditCounts.sorted { $0.value > $1.value }
                    var topSubreddits: [String: Int] = [:]
                    for (index, subredditCount) in sortedSubreddits.enumerated() {
                        if index >= 6 { break }
                        topSubreddits[subredditCount.key] = subredditCount.value
                    }
                    completion(topSubreddits, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }

    // This function is used to get the image of a post from its URL.
    func getPostImage(from url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image, nil)
            }
        }.resume()
    }
}
