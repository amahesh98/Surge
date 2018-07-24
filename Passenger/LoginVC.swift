//
//  ViewController.swift
//  Passenger
//
//  Created by Ashwin Mahesh on 7/23/18.
//  Copyright © 2018 AshwinMahesh. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func registerPushed(_ sender: UIButton) {
        performSegue(withIdentifier: "LoginToRegisterSegue", sender: "LoginToRegister")
    }
    
    @IBAction func loginPushed(_ sender: UIButton) {
        if clientValidate(){
            var notValid=false
            if let urlReq = URL(string: "\(SERVER.IP)/processLogin/"){
                var request = URLRequest(url:urlReq)
                request.httpMethod = "POST"
                let bodyData="email=\(emailField.text!)&password=\(passwordField.text!)"
                request.httpBody = bodyData.data(using: .utf8)
                let session = URLSession.shared
                let task = session.dataTask(with: request as URLRequest){
                    data, response, error in
                    do{
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary{
                            let response = jsonResult["response"] as! String
                            print("Response: \(response)")
                            if response == "User does not exist"{
                                DispatchQueue.main.async{
                                    self.alert(title: "Login failed", message: "User does not exist")
                                }
                            }
                            else if response == "Password does not match user"{
                                DispatchQueue.main.async{
                                    self.alert(title: "Login Failed", message: "Password does not match user")
                                }
                            }
                            else if response == "Login successful"{
                                DispatchQueue.main.async{
                                    notValid=true
                                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: "LoginToHome")
                                }
                            }
                        }
                    }
                    catch{
                        print(error)
                    }
                }
                task.resume()
                print(notValid)
                if notValid==true{
                    self.performSegue(withIdentifier: "LoginToHomeSegue", sender: "LoginToHome")
                }
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func alert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler: nil))
        self.present(alert, animated:true)
    }
    
    func clientValidate() -> Bool{
        if emailField.text!.count<5{
            DispatchQueue.main.async{
                self.alert(title: "Login Failed", message: "Invalid email")
            }
            return false
        }
        if passwordField.text!.count<8{
            DispatchQueue.main.async{
                self.alert(title: "Login Failed", message: "Password must be atleast 8 characters")
            }
            return false
        }
        return true
    }

}
