//
//  FormViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FormViewController: UIViewController {

    
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var tagEntryField: UITextField!
    @IBOutlet weak var tagTableView: UITableView!
    
    let db = Firestore.firestore()
    
    var tags: [String] = ["success", "or not?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagTableView.delegate = self
        tagTableView.dataSource = self

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
        print(entryText.text!)
    }
    
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        if let newTag = tagEntryField.text {
            tags.append(newTag)
            tagEntryField.text = ""
        }
        tagTableView.reloadData()
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
        // TODO: this function is where I can tell it what to do when the user clicks on an entry listed in the table
        print(indexPath.row)
    }
}
