//
//  CommonFunctions.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 2.03.2023.
//

import Foundation


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
                self.trendingPosts = redditResponse.data.children.map { $0.data.toRedditPost() }
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
