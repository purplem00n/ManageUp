//
//  FormViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import iOSDropDown

class FormViewController: UIViewController {


    @IBOutlet weak var tagEntryDropDown: DropDown!
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var tagTableView: UITableView!
    
    let db = Firestore.firestore()
    var tags: [String] = []
    
    var allTagsArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        
        tagEntryDropDown.optionArray = allTagsArray
        
        getAllUserTags()
        
    }

    
    @IBAction func submitPressed(_ sender: UIButton) {
        if let textBody = entryText.text, let user = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.textField: textBody, K.FStore.dateField: Date.now, K.FStore.userField: user, K.FStore.tagsField: tags]) { (error) in
                if let e = error {
                    print(e)
                } else {
                    print("Successfully saved data")
                }
            }
        }
    }
    
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        if let newTag = tagEntryDropDown.text {
            if !tags.contains(newTag) {
                tags.append(newTag)
            }
            tagEntryDropDown.text = ""
        }
        tagTableView.reloadData()
    }
    
    func getAllUserTags() {
        db.collection(K.FStore.collectionName).whereField(K.FStore.userField, isEqualTo: Auth.auth().currentUser?.email!).order(by: K.FStore.dateField, descending: true).addSnapshotListener {
            (querySnapshot, err) in
            
            self.allTagsArray = []
            
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let tags = data[K.FStore.tagsField] as? [String] {
                            for tag in tags {
                                if !self.allTagsArray.contains(tag) {
                                    self.allTagsArray.append(tag)
                                }
                            }
                        }
                    }
                }
                self.tagEntryDropDown.optionArray = self.allTagsArray
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
extension FormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableTagCell")
        cell?.textLabel?.text = tags[indexPath.row]
        return cell!
    }
}

extension FormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // remove tag item when the user clicks on an entry listed in the table.
        tags.remove(at: indexPath.row)
        tagTableView.reloadData()
    }
}
