//
//  ViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FSCalendar

class HomeViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet var calendar: FSCalendar!
    
    let db = Firestore.firestore()
    
    var datesWithEntry: [DateComponents] = []
    var selectedDate: Date = Date.now
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        findDatesWithEntries()
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)

    }
    
    func findDatesWithEntries() {

        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).addSnapshotListener {
                (querySnapshot, err) in

                self.datesWithEntry = []

                if let e = err {
                    print("Error getting documents: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let date = data[K.FStore.dateField] as? Timestamp {
                                let date = date.dateValue()
                                let dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: date)
                                if !self.datesWithEntry.contains(dateComponents) {
                                    self.datesWithEntry.append(dateComponents)
                                }
                            }
                        }
                    }
                    self.calendar.reloadData()
                }
            }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = calendar.selectedDate!
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: date)
        if datesWithEntry.contains(dateComponents) {
            return 1
        } else {
            return 0
        }
    }
    
    // let the segue send selected data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.searchSegue {
            if let searchViewController = segue.destination as? SearchViewController {
                searchViewController.selectedDate = selectedDate
            }
        }
        if segue.identifier == K.formSegue {
            if let formViewController = segue.destination as? FormViewController {
                formViewController.selectedDate = selectedDate
            }
        }
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

