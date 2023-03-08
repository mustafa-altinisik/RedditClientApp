//
//  Network Manager.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 4.03.2023.
//

import Foundation
import Alamofire


class RedditAPI{
    func getRedditPostsFromSubreddit(subredditName: String, safeSearch: Bool, onlyPostsWithImages: Bool, completion: @escaping ([RedditPost]?, Error?) -> Void) {
        let url = "https://www.reddit.com/r/\(subredditName)/.json"
        
        var parameters: Parameters = [:]
        if safeSearch {
            parameters["include_categories"] = 1
            parameters["include_over_18"] = 0
        }
        
        AF.request(url, parameters: parameters)
            .validate()
            .responseDecodable(of: RedditResponse.self) { response in
                switch response.result {
                case .success(let redditResponse):
                    var redditPosts = [RedditPost]()
                    for child in redditResponse.data.children {
                        if let imageURL = URL(string: child.data.thumbnail), onlyPostsWithImages && imageURL != URL(string: "default") {
                            redditPosts.append(child.data.toRedditPost())
                        } else if !onlyPostsWithImages {
                            redditPosts.append(child.data.toRedditPost())
                        }
                    }
                    completion(redditPosts, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }


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


    func getPostImage(from url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
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
