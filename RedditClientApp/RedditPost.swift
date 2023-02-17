//
//  RedditPost.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 17.02.2023.
//

import Foundation

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
