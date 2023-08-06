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
    
    var datesWithOneEntry: [Date] = []
    var datesWithMultEntries: [Date] = []
    var tempEntries: [Entry] = []
    var selectedDate: Date = Date.now
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)

    }
    
//    func countEntriesPerDay(date: Date) -> Int {
//        let calendar = Calendar.current
//        let fromDateReset = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
//        let toDateReset = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
//
//        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).whereField(K.FStore.dateField, isGreaterThan: fromDateReset).whereField(K.FStore.dateField, isLessThan: toDateReset).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
//                (querySnapshot, err) in
//
//                self.tempEntries = []
//
//                if let e = err {
//                    print("Error getting documents: \(e)")
//                } else {
//                    if let snapshotDocuments = querySnapshot?.documents {
//                        for doc in snapshotDocuments {
//                            let data = doc.data()
//                            if let text = data[K.FStore.textField] as? String, let user = data[K.FStore.userField] as? String, let tags = data[K.FStore.tagsField] as? [String], let date = data[K.FStore.dateField] as? Timestamp {
//                                let date = date.dateValue()
//                                let newEntry = Entry(user: user, id: doc.documentID, text: text, tags: tags, date: date)
//                                self.tempEntries.append(newEntry)
//                                print(newEntry)
//                                print("from date \(fromDateReset)")
//                                print("to date \(toDateReset)")
//                            }
//                        }
//                    }
//                }
//            }
//        print(tempEntries.count, date)
//        return tempEntries.count
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = calendar.selectedDate!
        print("home view selected Date \(selectedDate)")
    }
    
    // FSCalendarDataSource
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        return true
    }
    
    // let the segue send selected vars data to the next screen
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

