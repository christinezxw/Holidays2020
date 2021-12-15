//
//  SearchByNameViewController.swift
//  Holidays2020
//
//  Created by Xuanwei Zhang on 12/14/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift

class SearchByNameViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    var arrHolidayInfo : [HolidayInfo] = [HolidayInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arrHolidayInfo.removeAll()
        self.tblView.reloadData()
        if searchText.count < 5 {
            return
        }
        print("search for \(searchText)")
        getHolidaysFromSearch(searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHolidayInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let content = arrHolidayInfo[indexPath.row].date + ", " + arrHolidayInfo[indexPath.row].name
        cell.textLabel?.text = content
        return cell
    }
    
    func getSearchURL(_ searchText : String) -> String{
        return holidaySearchUrl + "&key=" + apiKey + "&search=" + searchText
    }
        
    func getHolidaysFromSearch(_ searchText : String) {
        // Network call from there
        let url = getSearchURL(searchText)
        SwiftSpinner.show("Getting Holidays...")
        AF.request(url).responseJSON { response in
            SwiftSpinner.hide()
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            // You will receive JSON array
            // Parse the JSON array
            // Add values in arrHolidayInfo
            // Reload table with the values
            let holidays = JSON( response.data!)["holidays"].array
            for holiday in holidays!{
                let holidayInfo = HolidayInfo()
                holidayInfo.name = holiday["name"].stringValue
                holidayInfo.date = holiday["date"].stringValue
                self.arrHolidayInfo.append(holidayInfo)
            }
            self.tblView.reloadData()
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // You will get the Index of the holiday info from here and then add it into the realm Database
//        // Once the holiday is added in the realm DB pop the navigation view controller
//        let holidayInfo = arrHolidayInfo[indexPath.row]
//        self.addHolidayInfoDB(holidayInfo)
//        print("click on \(indexPath.row) and save")
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let saveButton = UITableViewRowAction(style: .normal, title: "Save") { (rowAction, indexPath) in
            let holidayInfo = self.arrHolidayInfo[indexPath.row]
            self.addHolidayInfoDB(holidayInfo)
            print("click on \(indexPath.row) and save")
        }
        saveButton.backgroundColor = UIColor.systemBlue
        return [saveButton]
    }

    func addHolidayInfoDB(_ holidayInfo : HolidayInfo){
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(holidayInfo, update: .modified)
            }
            print("save into db")
        }catch{
            print("Error in getting values from DB \(error)")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
