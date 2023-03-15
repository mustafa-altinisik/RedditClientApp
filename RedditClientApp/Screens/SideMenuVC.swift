//
//  SideMenuVC.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.03.2023.
//

import UIKit

class SideMenuVC: UITableViewController {
    
    let categoriesWithSystemImageNames: [(category: String, systemImageName: String)] = [
        ("Science", "atom"),
        ("Sport", "sportscourt"),
        ("Technology", "iphone"),
        ("Photography", "camera.fill"),
        ("News", "newspaper.fill"),
        ("Politics", "person.2.fill")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SideMenuPredefinedCategoryTVC.self, forCellReuseIdentifier: "predefinedCategoryCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesWithSystemImageNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predefinedCategoryCell", for: indexPath) as! SideMenuPredefinedCategoryTVC
        
        let categoryWithImage = categoriesWithSystemImageNames[indexPath.row]
        
        cell.categoryButton.setTitle(categoryWithImage.category, for: .normal)
        cell.categoryButton.setImage(UIImage(systemName: categoryWithImage.systemImageName), for: .normal)
        
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
