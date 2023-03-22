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
    
    func displayAlertMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Function to display the animation
    func displayRedditLogoAnimation() -> (animationView: LottieAnimationView, overlayView: UIView) {
        // Create a new view to cover the screen
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = .white
        
        // Add the overlay view on top of the current view
        self.view.addSubview(overlayView)
        
        // Create the Lottie animation view as before
        let animationView = LottieAnimationView(name: "redditAnimation")
        animationView.loopMode = .loop
        animationView.play()
        
        // Set the frame and background color of the animation view
        let size = CGSize(width: 150, height: 150)
        animationView.frame = CGRect(origin: .zero, size: size)
        animationView.center = self.view.center
        
        // Add the animation view to the overlay view
        overlayView.addSubview(animationView)
        
        return (animationView, overlayView)
    }

    // Function to hide the animation
    func hideRedditLogoAnimation(animation: (animationView: LottieAnimationView, overlayView: UIView)) {
        // Stop the animation and remove the animation view
        animation.animationView.stop()
        animation.animationView.removeFromSuperview()
        // Remove the overlay view
        animation.overlayView.removeFromSuperview()
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
