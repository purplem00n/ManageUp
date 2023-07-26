//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SearchViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = []
//    [
//        Entry(user:"1@2.com", date: Date.now, text: "This is a test entry", tags:["success", "capstone"]),
//        Entry(user:"1@2.com", date: Date.now, text: "Add entries to table view", tags: ["success", "organization"]),
//        Entry(user: "1@2.com", date: Date.now, text: "Complete another story!", tags: ["accomplishment"])
//    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        loadEntries()
        
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
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        cell?.textLabel?.text = entries[indexPath.row].text
//        cell?.textLabel?.text = K.FStore.collectionName[indexPath.row].data.textField
        return cell!
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: this function is where I can tell it what to do when the user clicks on an entry listed in the table
        print(indexPath.row)
    }
}
