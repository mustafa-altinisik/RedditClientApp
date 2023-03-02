//
//  RedditPost.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation

//This struct is used to store the data of a single post
struct RedditPost {
    var imageURL: String
    var title: String
    var description: String
    var permalink: String
    var over_18: Bool

  init(imageURL: String, title: String, description: String, permalink: String, over_18: Bool) {
    self.imageURL = imageURL
    self.title = title
    self.description = description
    self.permalink = permalink
    self.over_18 = over_18
  }
}
