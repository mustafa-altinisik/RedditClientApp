//
//  toPostsScreen.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 2.03.2023.
//

import UIKit

class toPostsScreen: UIStoryboardSegue {
    override func perform() {
        // Add any custom transition code here
        let source = self.source
        let destination = self.destination
        
        destination.modalPresentationStyle = .fullScreen
        source.present(destination, animated: false, completion: nil)

    }
}
