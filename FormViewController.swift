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
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if let textBody = entryText.text, let user = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.textField: textBody, K.FStore.dateField: Date.now, K.FStore.userField: user, K.FStore.tagsField: ["Example Tag"]]) { (error) in
                if let e = error {
                    print(e)
                } else {
                    print("Successfully saved data")
                }
            }
        }
        print(entryText.text!)
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
