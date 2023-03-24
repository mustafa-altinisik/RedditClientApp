//
//  SideMenuViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.03.2023.
//

import UIKit

final class SideMenuViewContoller: UITableViewController {

    private let neworkManager = NetworkManager()
    private let baseClass = BaseViewController()
    
    struct categoriesWithSystemImageNamesStruct {
        var categoryName: String
        var categoryIcon: String
        var sectionNumber: Int
    }
    
    struct settingsStruct {
        var settingName: String
        var defaultsValue: String
        var sectionNumber: Int
    }

    let categoriesArray = [categoriesWithSystemImageNamesStruct(categoryName: "Science", categoryIcon: "atom", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "Sports", categoryIcon: "sportscourt", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "Technology", categoryIcon: "iphone", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "Photography", categoryIcon: "camera", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "News", categoryIcon: "newspaper", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "Politics", categoryIcon: "person.2", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryName: "World", categoryIcon: "globe", sectionNumber: 1)]
    
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
            return categoriesArray.count
        } else if section == 1 {
            return 2
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "predefinedCategoryCell", for: indexPath) as? SideMenuPredefinedCategoryTVC else {
                return UITableViewCell()
            }

            let categoryWithImage = categoriesArray[indexPath.row]

            cell.categoryButton.setTitle(categoryWithImage.categoryName, for: .normal)
            cell.categoryButton.setImage(UIImage(systemName: categoryWithImage.categoryIcon), for: .normal)

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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: categoriesArray[indexPath.row].categoryName)
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
