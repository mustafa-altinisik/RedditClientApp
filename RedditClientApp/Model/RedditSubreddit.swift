//
//  RedditSubreddit.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 6.03.2023.
//

import Foundation

struct TrendingSubredditsResponse: Decodable {
    struct Data: Decodable {
        struct Child: Decodable {
            let data: ChildData
        }
        let children: [Child]
    }
    let data: Data
}

struct ChildData: Decodable {
    let subreddit: String
}
