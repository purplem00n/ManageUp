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
    
    var tags: [String: String] = [:]
    
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
    }
    
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        if let newTag = tagEntryField.text {
            
            // check if new tag is in existing tags, if so do nothing
            // if not in existing tags:
            tags[newTag] = "red" // will need to add color: based on a long list of colors, add the color at the following index, and increment the index for next time.
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
//        cell?.textLabel?.text = ??? // this needs to be the string that is the key in the dictionary, I don't know how to access that, the only way I have is by index
        // this might not be a problem if I decide another method of adding tags.
        //doesn't work:
//        for (key, value) in tags {
//            cell?.textLabel?.text = key
//        }
        // tags[indexPath.row] was what worked when tags was a list instead of dictionary
        return cell!
    }
}

extension FormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // remove tag item when the user clicks on an entry listed in the table. Not sure how to access the keyString.
//        tags.removeValue(forKey: <#T##String#>)
        tagTableView.reloadData()
    }
}
