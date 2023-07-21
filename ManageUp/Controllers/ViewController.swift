//
//  ViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func addEntryPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "goToEntryForm", sender: self)
        
    }
    
}

