//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = []
    var filteredEntries: [Entry] = []
    var allTags: [String] = []
    let df = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self

        
        loadEntries()
//        getAllTags()
    }
    
    func loadEntries() {
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
            (querySnapshot, err) in
            
            self.entries = []
            
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let text = data[K.FStore.textField] as? String, let user = data[K.FStore.userField] as? String, let tags = data[K.FStore.tagsField] as? [String] {
                            let newEntry = Entry(user: user, text: text, tags: tags)
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredEntries = []
        if searchText == "" {
            filteredEntries = entries
        }
        for entry in entries {
            for tag in entry.tags {
                if tag.uppercased().contains(searchText.uppercased()) {
                    filteredEntries.append(entry)
                }
            }
            if entry.text.uppercased().contains(searchText.uppercased()) {
                filteredEntries.append(entry)
            }
        }
        tableView.reloadData()
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


//populates table view
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        cell?.detailTextLabel?.text = "DATE"  // entries[indexPath.row].date
//        DOESN'T WORK: need to get subtitle to be the date -- convert date to string type somehow
        cell?.textLabel?.text = filteredEntries[indexPath.row].text
        return cell!
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: this function is where I can tell it what to do when the user clicks on an entry listed in the table
        print(indexPath.row)
    }
}


