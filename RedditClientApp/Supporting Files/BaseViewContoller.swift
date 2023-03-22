//
//  BaseViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 21.03.2023.
//

import Foundation
import UIKit
import Lottie

class BaseViewController: UIViewController{
    let animationView = LottieAnimationView(name: "redditAnimation")
    
    // This function shows the PostsScreenViewContoller when a subreddit is selected.
    func showPostsScreen(subredditToBeDisplayed: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "postsScreen") as? PostsScreenViewContoller {
                vc.subredditName = subredditToBeDisplayed
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            }
        }
    }
    
    func displayAlertMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Function to display the animation
    func displayRedditLogoAnimation() -> LottieAnimationView {
        animationView.loopMode = .loop
        animationView.play()
        
        // Define the size of the animation view
        let size = CGSize(width: 100, height: 100)
        
        // Set the frame of the animation view
        animationView.frame = CGRect(origin: .zero, size: size)
        animationView.center = self.view.center
        
        self.view.addSubview(animationView)
        return animationView
    }

    // Function to hide the animation
    func hideRedditLogoAnimation(_ animationView: LottieAnimationView) {
        animationView.stop()
        animationView.removeFromSuperview()
    }
    
    func displayRedditPost(postToBeDisplayed: RedditPostData){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "webScreen") as? WebScreenViewController {
            if let permalink = postToBeDisplayed.permalink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: "https://www.reddit.com/\(permalink)") {
                vc.setPostDetails(urlOfThePost: url, titleOfThePost: postToBeDisplayed.title)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            }
        }
    }
}
