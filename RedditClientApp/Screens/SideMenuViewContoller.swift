//
//  SideMenuViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.03.2023.
//

import UIKit
final class SideMenuViewContoller: UITableViewController {
    
    private let neworkManager = NetworkManager()
    
    private let categoriesWithSystemImageNames: [(category: String, systemImageName: String)] = [
        ("Science", "atom"),
        ("Sport", "sportscourt"),
        ("Technology", "iphone"),
        ("Photography", "camera"),
        ("News", "newspaper"),
        ("Politics", "person.2"),
        ("World", "globe")
    ]
    
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SideMenuPredefinedCategoryTVC.self, forCellReuseIdentifier: "predefinedCategoryCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Categories"
        } else if section == 1 {
            return "Settings"
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categoriesWithSystemImageNames.count
        } else if section == 1 {
            return 2
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "predefinedCategoryCell", for: indexPath) as! SideMenuPredefinedCategoryTVC
            
            let categoryWithImage = categoriesWithSystemImageNames[indexPath.row]
            
            cell.categoryButton.setTitle(categoryWithImage.category, for: .normal)
            cell.categoryButton.setImage(UIImage(systemName: categoryWithImage.systemImageName), for: .normal)
            
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Safe Search"
                let safeSearchSwitch = UISwitch()
                safeSearchSwitch.isOn = defaults.bool(forKey: "safeSearch")
                safeSearchSwitch.addTarget(self, action: #selector(safeSearchSwitchValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = safeSearchSwitch
            } else if indexPath.row == 1 {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = "Posts with Images Only"
                let imagesOnlySwitch = UISwitch()
                imagesOnlySwitch.isOn = defaults.bool(forKey: "postsWithImages")
                imagesOnlySwitch.addTarget(self, action: #selector(imagesOnlySwitchValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = imagesOnlySwitch
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: categoriesWithSystemImageNames[indexPath.row].category)
    }
    
    func showPostsScreen(subredditToBeDisplayed: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "postsScreen") as? PostsScreenViewContoller {
                vc.subredditName = subredditToBeDisplayed
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    // Handle value change of safeSearchSwitch
    @objc func safeSearchSwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "safeSearch")
    }
    
    // Handle value change of imagesOnlySwitch
    @objc func imagesOnlySwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "postsWithImages")
    }
}
