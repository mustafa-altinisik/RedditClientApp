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
    func displayRedditLogoAnimation() -> LottieAnimationView {
        let animationView = LottieAnimationView(name: "redditAnimation")
        animationView.loopMode = .loop
        animationView.play()
        
        // Define the size of the animation view
        let size = CGSize(width: 100, height: 100)
        
        // Set the frame of the animation view
        animationView.frame = CGRect(origin: .zero, size: size)
        
        // Center the animation view in its superview
        if let superview = animationView.superview {
            animationView.center = superview.center
        }
        
        return animationView
    }


    // Function to hide the animation
    func hideRedditLogoAnimation(_ animationView: LottieAnimationView) {
        animationView.stop()
        animationView.removeFromSuperview()
    }
}
