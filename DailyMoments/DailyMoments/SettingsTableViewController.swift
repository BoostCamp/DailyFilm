//
//  SettingsTableViewController.swift
//  DailyMoments
//
//  Created by 남상욱 on 2017. 2. 23..
//  Copyright © 2017년 nam. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SwitchCellDelegate {

    struct Sections {
        static let titles: [String?] = ["User Information", "System Settings"]
        
        static let rowTitles: [[String?]?] = [["아이디", "닉네임"],
                                              ["격자", "음성인식", "화면 비율"]]
        
        static func numberOfRows(of section: Int) -> Int {
            return rowTitles[section]?.count ?? 0
        }
        
        static func titleForIndexPath(_ indexPath: IndexPath) -> String? {
            return rowTitles[indexPath.section]?[indexPath.row]
        }
        
        static func cellIdentifier(for indexPath: IndexPath) -> String {
            switch indexPath.section {
            case 0:
                return "RightDetailCell"
            case 1:
                switch indexPath.row {
                case 0:
                    return "SwitchCell"
                default:
                    return "RightDetailCell"
                }
            default:
                return ""
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK:- View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return SettingsTableViewController.Sections.titles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Sections.numberOfRows(of: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Sections.titles[section]
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: Sections.cellIdentifier(for: indexPath), for: indexPath)
        cell.textLabel?.text = Sections.titleForIndexPath(indexPath)

        if let switchCell = cell as? SwitchCell {
            switchCell.onOffSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKey.cameraGuideLine)
            switchCell.delegate = self
            print(Sections.cellIdentifier(for: indexPath))
        } else {
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = UserDefaults.standard.string(forKey: UserDefaultsKey.userId)
            case 1:
                cell.detailTextLabel?.text = UserDefaults.standard.string(forKey: UserDefaultsKey.nickName)
            default:
                cell.detailTextLabel?.text = nil
            }
        }

        return cell
        
    }
    
    struct UserDefaultsKey {
        static let userId: String = "UserId"
        static let nickName: String = "NickName"
        static let cameraGuideLine: String =  "CameraGuideLine"
        
    }
    
    // MARK: - SwitchCellDelegate Methods
    
    func switchCellDidChangeSwitchValue(sender: SwitchCell) {
        if sender.textLabel?.text == Sections.titleForIndexPath(IndexPath.init(row: 0, section: 1)) {
            UserDefaults.standard.set(sender.onOffSwitch.isOn, forKey: UserDefaultsKey.cameraGuideLine)
            UserDefaults.standard.synchronize()
        }
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
