//
//  toHomeScreen.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 2.03.2023.
//

import UIKit

class toHomeScreen: UIStoryboardSegue {
    override func perform() {
        let source = self.source
        let destination = self.destination
        
        destination.modalPresentationStyle = .fullScreen
        source.present(destination, animated: false, completion: nil)
    }
}
