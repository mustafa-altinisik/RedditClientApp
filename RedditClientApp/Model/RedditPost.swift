//
//  RedditPost.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation

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
    let subreddit: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbnail
        case title
        case selftext
        case permalink
        case over_18
        case subreddit
    }
    
    // This function is used to convert the data from the API call to RedditPost struct
    func toRedditPost() -> RedditPost {
        if let subreddit = subreddit {
            return RedditPost(imageURL: thumbnail, title: title, description: selftext, permalink: permalink, over_18: over_18, subreddit: subreddit)
        } else {
            return RedditPost(imageURL: thumbnail, title: title, description: selftext, permalink: permalink, over_18: over_18, subreddit: "")
        }

    }

}


//This struct is used to store the data of a single post
struct RedditPost {
    var imageURL: String
    var title: String
    var description: String
    var permalink: String
    var over_18: Bool
    var subreddit: String
    
    init(imageURL: String, title: String, description: String, permalink: String, over_18: Bool, subreddit: String) {
        self.imageURL = imageURL
        self.title = title
        self.description = description
        self.permalink = permalink
        self.over_18 = over_18
        self.subreddit = subreddit
    }
}
