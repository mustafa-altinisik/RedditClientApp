//
//  RedditPost.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation

//This struct is used to store the data of a single post
struct RedditPost {
  let imageURL: String
  let title: String
  let description: String

  init(imageURL: String, title: String, description: String) {
    self.imageURL = imageURL
    self.title = title
    self.description = description
  }
}
