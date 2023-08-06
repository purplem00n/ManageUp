//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import iOSDropDown
import TTGTags

class SearchViewController: UIViewController, UISearchBarDelegate, TTGTextTagCollectionViewDelegate {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    @IBOutlet weak var tagSelector: DropDown!
    let ttgTagView = TTGTextTagCollectionView()
    
    var entries: [Entry] = []
    var filteredEntries: [Entry] = []
    var allTags: [String] = []
    var selectedTags: [String] = []
    var selectedEntry: Entry = Entry(user: "", id: "", text: "", tags: [], date: Date.now)
    var selectedDate: Date = Date.now
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // sets timezone to the time zone of the device
        fromDate.timeZone = TimeZone.current
        toDate.timeZone = TimeZone.current
        
        // initialize tag view
        ttgTagView.frame = CGRect(x: 20, y: 275, width: view.frame.size.width, height: 50)
        ttgTagView.alignment = .left
        ttgTagView.delegate = self
        view.addSubview(ttgTagView)
        
        tagSelector.optionArray = allTags
        
        loadEntries()
        getAllUserTags()
    }
    
    func loadEntries() {
        
//        if selectedDate != Date.now {
//
//        }
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
            (querySnapshot, err) in
            
            self.entries = []
            
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let text = data[K.FStore.textField] as? String, let user = data[K.FStore.userField] as? String, let tags = data[K.FStore.tagsField] as? [String], let date = data[K.FStore.dateField] as? Timestamp, let id = doc.documentID as? String {
                            let date = date.dateValue()
                            let newEntry = Entry(user: user, id: id, text: text, tags: tags, date: date)
                            self.entries.append(newEntry)
                        }
                    }
                    self.filteredEntries = self.entries
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    } // this makes sure the table updates with the most current data.
                }
            }
        }
    }
    // THIS WORKS to search text and tag field with date range
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//
//        let calendar = Calendar.current
//        let fromDateReset = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: fromDate.date)!
//        let toDateReset = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: toDate.date)!
//
//        filteredEntries = []
//        if searchText == "" {
//            filteredEntries = entries
//        }
//
//        for entry in entries {
//            for tag in entry.tags {
//                if tag.uppercased().contains(searchText.uppercased()) && entry.date <= toDateReset && entry.date >= fromDateReset {
//                    filteredEntries.append(entry)
//                    print(entry.date, fromDateReset, toDateReset)
//                }
//            }
//            if entry.text.uppercased().contains(searchText.uppercased()) && entry.date <= toDateReset && entry.date >= fromDateReset {
//                filteredEntries.append(entry)
//            }
//        }
//
//        tableView.reloadData()
//    }
    
    //TESTING
    // This logic is inside the search bar function, which means that it's requiring the text in the search bar to change before executing. I need a different initializer for this logic.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let calendar = Calendar.current
        let fromDateReset = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: fromDate.date)!
        let toDateReset = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: toDate.date)!
        
        if selectedTags != [] {
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
                                if newEntry.text.uppercased().contains(searchText.uppercased()) {
                                    self.filteredEntries.append(newEntry)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            print(self.filteredEntries.count)
                        } // this makes sure the table updates with the most current data.
                    }
                }
            }
        } else {
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
                                if newEntry.text.uppercased().contains(searchText.uppercased()) {
                                    self.filteredEntries.append(newEntry)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            print(self.filteredEntries.count)
                        } // this makes sure the table updates with the most current data.
                    }
                }
            }
        }

        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let calendar = Calendar.current
        let fromDateReset = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: fromDate.date)!
        let toDateReset = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: toDate.date)!
        
        if selectedTags != [] {
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
                                if self.searchBar.text != "" {
                                    if newEntry.text.uppercased().contains(self.searchBar.text!.uppercased()) {
                                        self.filteredEntries.append(newEntry)
                                    }
                                } else {
                                    self.filteredEntries.append(newEntry)
                                }
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                print(self.filteredEntries.count)
                            } // this makes sure the table updates with the most current data.
                        }
                    }
                }
            }
        } else {
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
                                if self.searchBar.text != "" {
                                    if newEntry.text.uppercased().contains(self.searchBar.text!.uppercased()) {
                                        self.filteredEntries.append(newEntry)
                                    }
                                } else {
                                    self.filteredEntries.append(newEntry)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            print(self.filteredEntries.count)
                        } // this makes sure the table updates with the most current data.
                    }
                }
            }
        }

    }
    
    
    // let the segue send selected vars data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.entrySegue {
            if let entryViewController = segue.destination as? EntryViewController {
                entryViewController.entry = selectedEntry
            }
        }
    }

    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        // remove tags on tap
        ttgTagView.removeTag(tag)
        ttgTagView.reload()
        // remove from tags list
        selectedTags.remove(at: Int(index))
    }
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        if let newTag = tagSelector.text, tagSelector.text != "" {
            if allTags.contains(newTag) {
                let textTag = TTGTextTag(content: TTGTextTagStringContent(text: newTag), style: TTGTextTagStyle())
                ttgTagView.addTag(textTag)
                ttgTagView.reload()
                if !selectedTags.contains(newTag) {
                    selectedTags.append(newTag)
                }
                tagSelector.text = ""
            } else {
                // pop up error message?
                print("Must choose an existing tag")
            }
        }
    }
    
    
    func getAllUserTags() {
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
                self.tagSelector.optionArray = self.allTags
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func formatDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd"
        return df.string(from:date)
    }
    
}


//populates table view
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        let dateString = formatDate(date: filteredEntries[indexPath.row].date)
        cell?.detailTextLabel?.text = dateString
        cell?.textLabel?.text = String(filteredEntries[indexPath.row].text.prefix(33))
        return cell!
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // this function is the action upon tapping on a table row
        selectedEntry = filteredEntries[indexPath.row]
        performSegue(withIdentifier: K.entrySegue, sender: self)
    }
}


