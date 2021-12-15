//
//  HomeViewController.swift
//  Holidays2020
//
//  Created by Xuanwei Zhang on 12/14/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var arrHolidayInfo : [HolidayInfo] = [HolidayInfo]()
    
    @IBOutlet weak var tblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentHolidays()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            do{
                let realm = try Realm()
                let infoObj = arrHolidayInfo[indexPath.row]
                try realm.write{
                    realm.delete(realm.objects(HolidayInfo.self).filter("name == %@", infoObj.name))
                }
            }catch{
                print("Error in deleting value from DB \(error)")
            }
            
            self.arrHolidayInfo.remove(at: indexPath.row)
            self.tblView.reloadData()
        }

    }
    
    func loadCurrentHolidays(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        do{
            let realm = try Realm()
            let holidayInfos = realm.objects(HolidayInfo.self)
            self.arrHolidayInfo.removeAll()
            for holidayInfo in holidayInfos{
                    self.arrHolidayInfo.append(holidayInfo)
                }
               self.tblView.reloadData()
        }catch{
            print("Error in reading Database \(error)")
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
