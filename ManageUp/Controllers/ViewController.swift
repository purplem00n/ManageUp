//
//  ViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth
import FSCalendar

class HomeViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)

    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.scope = .week
        print(date)
    }
    
    // FSCalendarDataSource
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return true
    }
    

    @IBAction func addEntryPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.formSegue, sender: self)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.searchSegue, sender: self)
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

