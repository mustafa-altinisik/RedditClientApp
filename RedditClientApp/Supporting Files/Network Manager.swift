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
    // This function is used to get the posts from a subreddit.
    func getRedditPostsFromSubreddit(subredditName: String,
                                     safeSearch: Bool,
                                     onlyPostsWithImages: Bool,
                                     completion: @escaping ([RedditPostData]?, Error?) -> Void) {
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
                    var redditPosts = [RedditPostData]()
                    for child in redditResponse.data.children {
                        if let imageURL = URL(string: child.data.imageURL),
                            onlyPostsWithImages && self.isImageURL(imageURL.absoluteString) {
                            //123123 ayni islemi yapmis direk donmeli
                            redditPosts.append(child.data)
                        } else if !onlyPostsWithImages {
                            redditPosts.append(child.data)
                        }
                    }
                    completion(redditPosts, nil)
                case .failure(let error):
                    completion(nil, error)
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
                    //123123 response direk yolla diger tarafta hsndle edersin
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

    // This function is used to check if a URL is an image URL.
    func isImageURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else {
            return false
        }

        if url.scheme == "http" || url.scheme == "https" {
            let ext = url.pathExtension.lowercased()
            return ["jpg", "jpeg", "png", "gif"].contains(ext)
        }

        return false
    }
}
