//
//  WebScreenViewController.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 22.03.2023.
//

import UIKit
import WebKit
import Lottie



final class WebScreenViewController: BaseViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var postTitleLabel: UILabel!
    
    private var redditPostURL = URL(string: "https://www.reddit.com")
    private var postsTitle: String = ""
    var redditAnimation = LottieAnimationView(name: "redditAnimation")

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let request = URLRequest(url: urlOfThePost)
        webView.load(request)
    }
}
