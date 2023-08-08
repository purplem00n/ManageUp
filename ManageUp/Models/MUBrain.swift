//
//  MUBrain.swift
//  ManageUp
//
//  Created by Ariel Higuera on 8/7/23.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FSCalendar
import iOSDropDown

class MUBrain {
    
    let db = Firestore.firestore()
    var datesWithEntry: [DateComponents: Int] = [:]
    var selectedDate: Date = Date.now
    var entries: [Entry] = []
    var filteredEntries: [Entry] = []
    var allTags: [String] = []
    var selectedTags: [String] = []
    var selectedEntry: Entry = Entry(user: "", id: "", text: "", tags: [], date: Date.now)
    var fromDateReset: Date = Date.now
    var toDateReset: Date = Date.now
    var todayMidnight: Date = Date.now
    
    
    func findDatesWithEntries(_ calendar: FSCalendar) {
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).getDocuments() {
                (querySnapshot, err) in

                self.datesWithEntry = [:]

                if let e = err {
                    print("Error getting documents: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let date = data[K.FStore.dateField] as? Timestamp {
                                let date = date.dateValue()
                                let dateComponents = Calendar.current.dateComponents([.month, .day, .year], from: date)
                                self.datesWithEntry[dateComponents] = (self.datesWithEntry[dateComponents] ?? 0) + 1
                            }
                        }
                    }
                    calendar.reloadData()
                }
            }
    }
    
    func resetDate(date: Date) {
        let calendar = Calendar.current
        fromDateReset = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        toDateReset = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        todayMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date.now)!
    }
    
    func convertDateToDateComponents(date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.month, .day, .year], from: date)
    }
    
    func loadEntries(fromDate: UIDatePicker, toDate: UIDatePicker, tableView: UITableView) {
        resetDate(date: selectedDate)
        
        if convertDateToDateComponents(date: fromDateReset) == convertDateToDateComponents(date: todayMidnight) {
            fromDateReset = fromDate.date
            toDateReset = toDate.date
        }
        queryEntriesWithDates(tableView: tableView)
    }
    
    func handleSubmission(entryText: String?, screen: UIViewController) {
        // if text box is empty, display alert and do not submit
        if entryText == "" {
            displayAlert(message:K.AlertMessage.noTextError, screen: screen)
            return
        }
        // To add a new entry
        if selectedEntry.id == "" {
            if let textBody = entryText, let user = Auth.auth().currentUser?.email {
                db.collection(K.FStore.collectionName).document().setData([K.FStore.textField: textBody, K.FStore.dateField: selectedDate, K.FStore.userField: user, K.FStore.tagsField: selectedTags]) { (error) in
                    if let e = error {
                        print(e)
                    } else {
//                        print(self.date.date)
                        screen.performSegue(withIdentifier: K.submitSegue, sender: self)
                        print("Successfully saved data.")
                    }
                }
            }
            // edit an existing entry
        } else {
            if let textBody = entryText, let user = Auth.auth().currentUser?.email {
                db.collection(K.FStore.collectionName).document(selectedEntry.id).setData([K.FStore.textField: textBody, K.FStore.dateField: selectedEntry.date, K.FStore.userField: user, K.FStore.tagsField: selectedTags]) { (error) in
                    if let e = error {
                        print(e)
                    } else {
                        screen.performSegue(withIdentifier: K.submitSegue, sender: self)
                        print("Successfully saved data.")
                    }
                }
            }
        }
        // clear selected entry data after submitting a new entry
        resetSelectedEntry()
    }
    
    func queryEntriesWithDates(tableView: UITableView) {
        //query with date params only, desc order by date
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).whereField(K.FStore.dateField, isGreaterThan: fromDateReset).whereField(K.FStore.dateField, isLessThan: toDateReset).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
            (querySnapshot, err) in
            
            self.filteredEntries = []
            
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let text = data[K.FStore.textField] as? String, let user = data[K.FStore.userField] as? String, let tags = data[K.FStore.tagsField] as? [String], let date = data[K.FStore.dateField] as? Timestamp {
                            let date = date.dateValue()
                            let newEntry = Entry(user: user, id: doc.documentID, text: text, tags: tags, date: date)
                            self.filteredEntries.append(newEntry)
                        }
                    }
                    DispatchQueue.main.async {
                        tableView.reloadData()
                        //                            print(self.filteredEntries.count)
                    } // this makes sure the table updates with the most current data.
                }
            }
        }
    }
    
    func queryWithDateTags(tableView: UITableView) {
        // query with date and tag
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).whereField(K.FStore.dateField, isGreaterThan: fromDateReset).whereField(K.FStore.dateField, isLessThan: toDateReset).whereField(K.FStore.tagsField, arrayContainsAny: selectedTags).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
            (querySnapshot, err) in
            
            self.filteredEntries = []
            
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let text = data[K.FStore.textField] as? String, let user = data[K.FStore.userField] as? String, let tags = data[K.FStore.tagsField] as? [String], let date = data[K.FStore.dateField] as? Timestamp {
                            let date = date.dateValue()
                            let newEntry = Entry(user: user, id: doc.documentID, text: text, tags: tags, date: date)
                            self.filteredEntries.append(newEntry)
                        }
                    }
                    DispatchQueue.main.async {
                        tableView.reloadData()
                        //                            print(self.filteredEntries.count)
                        // display a message if count == 0 ??
                    } // this makes sure the table updates with the most current data.
                }
            }
        }
    }
    
    func textSearch(searchText: String, tableView: UITableView) {
        // not working yet
        var textInEntry: [Entry] = []
        
        if selectedTags == [] {
            queryEntriesWithDates(tableView: tableView)
        } else {
            queryWithDateTags(tableView: tableView)
        }
        
        if searchText == "" {
            filteredEntries = entries
        }
        
        for entry in filteredEntries {
            if entry.text.uppercased().contains(searchText.uppercased()) {
                textInEntry.append(entry)
            }
        }
        filteredEntries = textInEntry
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
    
    func displayDate() -> Date {
        let todayDateComponents = convertDateToDateComponents(date: Date.now)
        let entryValueDateComponents = convertDateToDateComponents(date: selectedEntry.date)
        
        // in the date display, show either the date passed from the form if we're editing an entry, or from the selected date on the calendar
        if entryValueDateComponents != todayDateComponents {
            return selectedEntry.date
        } else {
            return selectedDate
        }
    }
    
    func displayAlert(message: String, screen: UIViewController) {
        // Declare Alert message
        let dialogMessage = UIAlertController(title: K.AlertMessage.errorTitle, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        
        // Present dialog message to user
        screen.present(dialogMessage, animated: true, completion: nil)
    }
    
    func getAllUserTags(tagSelector: DropDown) {
            db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
                (querySnapshot, err) in
    
                self.allTags = []
    
                if let e = err {
                    print("Error getting documents: \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let tags = data[K.FStore.tagsField] as? [String] {
                                for tag in tags {
                                    if !self.allTags.contains(tag) {
                                        self.allTags.append(tag)
                                    }
                                }
                            }
                        }
                    }
                    tagSelector.optionArray = self.allTags
                }
            }
        }
    
    func formatDate(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from:date)
    }
    
    func resetSelectedEntry() {
        selectedEntry = Entry(user: "", id: "", text: "", tags: [], date: Date.now)
    }
    
    func logout(screen: UIViewController) {
        do {
            try Auth.auth().signOut()
            screen.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
    
