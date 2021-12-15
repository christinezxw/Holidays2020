//
//  SearchByDateViewController.swift
//  Holidays2020
//
//  Created by Xuanwei Zhang on 12/14/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Foundation
import RealmSwift

class SearchByDateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var arrHolidayInfo : [HolidayInfo] = [HolidayInfo]()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tblView: UITableView!
    
    @IBAction func dataPickerChanged(_ sender: Any) {
        self.arrHolidayInfo.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let month: String = dateFormatter.string(from: self.datePicker.date)
        dateFormatter.dateFormat = "dd"
        let day: String = dateFormatter.string(from: self.datePicker.date)
        print("select day = \(day) and month = \(month)")
        getHolidaysFromDate(day: day, month: month)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func getSearchURL(day : String, month : String) -> String{
        return holidaySearchUrl + "&key=" + apiKey + "&month=" + month + "&day=" + day
    }
        
    func getHolidaysFromDate(day : String, month : String) {
        // Network call from there
        let url = getSearchURL(day : day, month: month)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
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
