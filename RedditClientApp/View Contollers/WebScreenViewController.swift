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
        let (animationView, overlayView) = displayRedditLogoAnimation()
        let request = URLRequest(url: urlOfThePost)
        webView.load(request)

        // Start the timer to check if the web view is loaded
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.isWebViewLoaded {
                self.hideRedditLogoAnimation(animation: (animationView, overlayView))
                self.timer?.invalidate()
            }
        }
    }

    // This function sets the boolean variable to true when the web view is loaded.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isWebViewLoaded = true
    }
}
