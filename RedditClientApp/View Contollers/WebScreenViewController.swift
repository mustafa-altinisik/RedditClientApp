//
//  WebScreenViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 22.03.2023.
//

import UIKit
import WebKit
import Lottie

final class WebScreenViewController: BaseViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var postTitleLabel: UILabel!

    private var redditPostURL = URL(string: "https://www.reddit.com")
    private var postsTitle: String = ""

    private var timer: Timer?
    private var isWebViewLoaded: Bool = false
    
    var animationView = LottieAnimationView(name: "redditAnimation")
    var overlayView = UIView(frame: UIScreen.main.bounds)


    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        openRedditPost(urlOfThePost: redditPostURL!)
        postTitleLabel.text = postsTitle
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }

    func setPostDetails(urlOfThePost: URL, titleOfThePost: String){
        redditPostURL = urlOfThePost
        postsTitle = titleOfThePost
    }

    private func openRedditPost(urlOfThePost: URL) {
        (animationView, overlayView) = displayRedditLogoAnimation()
        let request = URLRequest(url: urlOfThePost)
        webView.load(request)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideRedditLogoAnimation(animation: (animationView, overlayView))
    }
}
