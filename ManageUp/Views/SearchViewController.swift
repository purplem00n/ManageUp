//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    var entries: [Entry] = []
    var allTags: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        loadEntries()
//        getAllTags()
        queryForAllTags()
    }
    
    func loadEntries() {

        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
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

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            } // this makes sure the table updates with the most current data.
                        }
                    }
                }
            }
        }
    }
    
    func getAllTags() {
        let snapshotDocuments = db.collection(K.FStore.collectionName)
        snapshotDocuments.getDocuments { querySnapshot, error in
            
            self.allTags = []
            
            if let e = error {
                print(e)
            } else {
                for document in querySnapshot!.documents {
                    let entry = document.data()
                    if let tags = entry["tags"] as? [String] {
                        for tag in tags {
                            if !self.allTags.contains(tag) {
                                self.allTags.append(tag)
                            }
                        }
                    }
                }
            }
//            print(self.allTags) THIS FUNC WORKS, but I should be using a query instead....
        }
    }
            
    func queryForAllTags() {
        let allTagsByQuery = db.collection(K.FStore.collectionName).whereField(K.FStore.tagsField, isNotEqualTo: [] as NSArray)
        print(allTagsByQuery)
        let objectType = type(of: allTagsByQuery)
        print(objectType)
        //returns a FIRQuery data object. Not sure how to parse this
        
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
        try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        print(text)
    }
}


//populates table view
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        cell?.textLabel?.text = entries[indexPath.row].text
        return cell!
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: this function is where I can tell it what to do when the user clicks on an entry listed in the table
        print(indexPath.row)
    }
}
