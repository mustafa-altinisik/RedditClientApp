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
    
    // This function displays an alert message as a popup.
    func displayAlertMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // This function displays the reddit logo animation.
    func displayRedditLogoAnimation() -> (animationView: LottieAnimationView, overlayView: UIView) {
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = .white
        self.view.addSubview(overlayView)
        
        let animationView = LottieAnimationView(name: "redditAnimation")
        animationView.loopMode = .loop
        animationView.play()
        
        let size = CGSize(width: 150, height: 150)
        animationView.frame = CGRect(origin: .zero, size: size)
        animationView.center = self.view.center
        overlayView.addSubview(animationView)
        
        return (animationView, overlayView)
    }

    // This function hides the reddit logo animation.
    func hideRedditLogoAnimation(animation: (animationView: LottieAnimationView, overlayView: UIView)) {
        animation.animationView.stop()
        animation.animationView.removeFromSuperview()
        animation.overlayView.removeFromSuperview()
    }
    
    // This function displays the WebScreenViewController when a post is selected.
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
