//
//  ViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // not sure if I want a title, it becomes the text instead of "back" on the following page.
//        title = "Manage Up: Home"
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }

    @IBAction func addEntryPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeToForm", sender: self)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeToSearch", sender: self)
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
        try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}

