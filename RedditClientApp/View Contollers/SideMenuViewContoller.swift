//
//  SideMenuViewContoller.swift
//  RedditClientApp
//
//  Created by Asım Altınışık on 15.03.2023.
//

import UIKit

// This protocol is used to trigger the functions in the PostsScreenViewContoller class.
protocol SideMenuActionDelegate: AnyObject {
    func safeSearchValueChanged(isOn: Bool)
    func postsWithImagesOnlyValueChanged(isOn: Bool)
}

final class SideMenuViewContoller: UITableViewController {
    
    // The delegate variable is used to trigger the functions in the PostsScreenViewContoller class.
    weak var sideMenuDelegate: SideMenuActionDelegate?
    
    // This struct is used to store the predefined category names and their system image names.
    struct categoriesWithSystemImageNamesStruct {
        var categoryRequestName: String
        var categoryNameToBeDisplayed: String
        var categoryIcon: String
        var sectionNumber: Int
    }
    
    // Section number might be used in tableView function in future.
    let categoriesArray = [categoriesWithSystemImageNamesStruct(categoryRequestName: "science", categoryNameToBeDisplayed: NSLocalizedString("science_string", comment: ""),                            categoryIcon: "atom", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "sports", categoryNameToBeDisplayed: NSLocalizedString("sports_string", comment: ""), categoryIcon: "sportscourt", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "technology", categoryNameToBeDisplayed: NSLocalizedString("technology_string", comment: ""), categoryIcon: "iphone", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "photography", categoryNameToBeDisplayed: NSLocalizedString("photography_string", comment: ""), categoryIcon: "camera", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "news", categoryNameToBeDisplayed: NSLocalizedString("news_string", comment: ""), categoryIcon: "newspaper", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "politics", categoryNameToBeDisplayed: NSLocalizedString("politics_string", comment: ""), categoryIcon: "person.2", sectionNumber: 1),
                           categoriesWithSystemImageNamesStruct(categoryRequestName: "global", categoryNameToBeDisplayed: NSLocalizedString("world_string", comment: ""), categoryIcon: "globe", sectionNumber: 1)]
    
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SideMenuPredefinedCategoryTVC.self, forCellReuseIdentifier: "predefinedCategoryCell")
    }

    // This function is used to determine the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // This function is used to determine the title of the sections in the table view.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("categories_string", comment: "")
        } else if section == 1 {
            return NSLocalizedString("settings_string", comment: "")
        }
        return nil
    }

    // This function is used to determine the number of rows in each section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categoriesArray.count
        } else if section == 1 {
            return 2
        }
        return 0
    }

    // This function is used to populate the table view cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "predefinedCategoryCell", for: indexPath) as? SideMenuPredefinedCategoryTVC else {
                return UITableViewCell()
            }

            let categoryWithImage = categoriesArray[indexPath.row]

            cell.categoryButton.setTitle(categoryWithImage.categoryNameToBeDisplayed, for: .normal)
            cell.categoryButton.setImage(UIImage(systemName: categoryWithImage.categoryIcon), for: .normal)

            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("SafeSearch_string", comment: "")
                let safeSearchSwitch = UISwitch()
                safeSearchSwitch.isOn = defaults.bool(forKey: UserDefaultsKeys.safeSearch)
                safeSearchSwitch.addTarget(self, action: #selector(safeSearchSwitchValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = safeSearchSwitch
            } else if indexPath.row == 1 {
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = NSLocalizedString("PostswithImagesOnly_string", comment: "")
                let imagesOnlySwitch = UISwitch()
                imagesOnlySwitch.isOn = defaults.bool(forKey: UserDefaultsKeys.postsWithImages)
                imagesOnlySwitch.addTarget(self, action: #selector(postsWithImagesSwitchValueChanged(_:)), for: .valueChanged)
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

    // This function is used to determine the height of the table view cells.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    // This function displays the posts screen with the selected category.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPostsScreen(subredditToBeDisplayed: categoriesArray[indexPath.row].categoryRequestName)
    }

    // This function is used to display the posts screen.
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
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKeys.safeSearch)
        sideMenuDelegate?.safeSearchValueChanged(isOn: sender.isOn)
    }

    // Handle value change of imagesOnlySwitch
    @objc func postsWithImagesSwitchValueChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKeys.postsWithImages)
        sideMenuDelegate?.postsWithImagesOnlyValueChanged(isOn: sender.isOn)
    }
}
