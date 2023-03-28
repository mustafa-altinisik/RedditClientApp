//
//  String+Ext.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 28.03.2023.
//

import Foundation

extension String {
    
    // This function is used to check if a URL is an image URL.
    func isImageURL() -> Bool {
        guard let url = URL(string: self) else {
            return false
        }
        if url.scheme == "http" || url.scheme == "https" {
            let ext = url.pathExtension.lowercased()
            return ["jpg", "jpeg", "png", "gif"].contains(ext)
        }
        return false
    }
}
