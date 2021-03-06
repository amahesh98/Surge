//
//  AdminDriversVC.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class AdminDriversVC: UIViewController {
    var orgNameText:String?
    @IBOutlet weak var orgName: UILabel!
    
    var orgID:Int?
    var tableData:[NSDictionary]=[]
    
    @IBAction func backPushed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPushed(_ sender: UIButton) {
        print("Pushing add")
        if let urlReq = URL(string: "\(SERVER.IP)/assignDriver/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "orgID=\(orgID!)&email=\(textField.text!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        if response=="User does not exist"{
                            let alert = UIAlertController(title: "Driver Add Error", message: "No user exists with that email address", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style:.default , handler: nil)
                            alert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(alert, animated:true)
                            }
                            return
                        }
                        else if response == "Driver added"{
                            let alert = UIAlertController(title: "Driver Successfully Added", message: "Driver successfully added to your organization", preferredStyle: .alert)
                            let ok=UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(alert, animated: true)
                                self.textField.text=""
                                self.fetchDrivers()
                            }
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    func fetchDrivers(){
        tableData=[]
        if let urlReq = URL(string: "\(SERVER.IP)/getOrgDrivers/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "orgID=\(orgID!)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
//                        print(jsonResult)
                        let response = jsonResult["response"] as! NSDictionary
                        let users = response["users"] as! NSMutableArray
                        for user in users{
                            let userFixed = user as! NSDictionary
                            self.tableData.append(userFixed)
                        }
                        DispatchQueue.main.async{
                            self.tableView.reloadData()
                        }
                    }
                }
                catch{
                    
                }
            }
            task.resume()
        }
    }
    
    @IBOutlet weak var textField: UITextField!
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate = self
        tableView.rowHeight=110
        print("OrgID is \(orgID!)")
        fetchDrivers()
        self.hideKeyboard()
        orgName.text = orgNameText!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension AdminDriversVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminDriverCell", for: indexPath) as! AdminDriverCell
        let currentDriver = tableData[indexPath.row]
        cell.nameLabel.text = (currentDriver["first_name"] as! String) + " " + (currentDriver["last_name"] as! String)
        cell.emailLabel.text=currentDriver["email"] as! String
        cell.phoneLabel.text=(currentDriver["phone_number"] as! String)
        cell.phoneNumber = currentDriver["phone_raw"] as! String
        cell.delegate=self
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, finishAnimation) in
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this driver?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
                finishAnimation(true)
                self.removeDriver(cell:tableView.cellForRow(at: indexPath) as! AdminDriverCell)
            }
            let no = UIAlertAction(title: "No", style: .cancel){
                action in
                finishAnimation(true)
                }
            alert.addAction(yes)
            alert.addAction(no)
            DispatchQueue.main.async{
                self.present(alert, animated: true)
            }
//            finishAnimation(true)
        }
        delete.backgroundColor = UIColor.red
        let swipeConfig = UISwipeActionsConfiguration(actions: [delete])
        return swipeConfig
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let text = UIContextualAction(style: .normal, title: "Text") { (action, view, finishAnimation) in
            let alert = UIAlertController(title: "Text Confirmation", message: "Do you want to proceed with sending this person a text?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
                self.sendMessage(cell: tableView.cellForRow(at: indexPath) as! AdminDriverCell)
            }
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            DispatchQueue.main.async{
                self.present(alert, animated: true)
            }
            finishAnimation(true)
        }
        text.backgroundColor = UIColor.init(red: CGFloat(79.0/255.0), green: CGFloat(143.0/255.0), blue: 0, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [text])
        return swipeConfig
    }
}
extension AdminDriversVC:AdminDriverCellDelegate{
    func sendMessage(cell:AdminDriverCell){
        let phoneNumber = cell.phoneNumber!
        let url = URL(string : "sms://\(phoneNumber)")!
        UIApplication.shared.open(url)
    }
    
    
    func removePushed(cell: AdminDriverCell) {
//        print("You are removing a cell")
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to remove this driver?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.removeDriver(cell:cell)
        }
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        DispatchQueue.main.async{
            self.present(alert, animated: true)
        }
    }
    
    func removeDriver(cell:AdminDriverCell){
        let email=cell.emailLabel.text!
//        print("Email: \(email)")
        if let urlReq = URL(string: "\(SERVER.IP)/removeDriver/"){
            var request = URLRequest(url: urlReq)
            request.httpMethod="POST"
            let bodyData = "email=\(email)"
            request.httpBody = bodyData.data(using:.utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
                do{
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                        print(jsonResult)
                        let response = jsonResult["response"] as! String
                        if response=="success"{
                            let alert = UIAlertController(title: "Driver Successfully Removed", message: "Driver successfully removed from your organization", preferredStyle: .alert)
                            let ok=UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alert.addAction(ok)
                            DispatchQueue.main.async{
                                self.present(alert, animated: true)
                                self.fetchDrivers()
                            }
                        }
                    }
                }
                catch{
                    print(error)
                }
            }
            task.resume()
        }
    }
}

