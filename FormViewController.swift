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
import TTGTags

class FormViewController: UIViewController, TTGTextTagCollectionViewDelegate {


    @IBOutlet weak var tagEntryDropDown: DropDown!
    @IBOutlet weak var entryText: UITextView!
    let ttgTagView = TTGTextTagCollectionView()
    
    let db = Firestore.firestore()
    var tags: [String] = []
    
    var allTagsArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLayoutSubviews()
        
        ttgTagView.frame = CGRect(x: 20, y: 148, width: view.frame.size.width, height: 150)
        ttgTagView.alignment = .left
        ttgTagView.delegate = self
        view.addSubview(ttgTagView)
        
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
            let textTag = TTGTextTag(content: TTGTextTagStringContent(text: newTag), style: TTGTextTagStyle())
            ttgTagView.addTag(textTag)
            ttgTagView.reload()
            if !tags.contains(newTag) {
                tags.append(newTag)
            }
            tagEntryDropDown.text = ""
        }
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        // remove tags on tap
        ttgTagView.removeTag(tag)
        ttgTagView.reload()
        // remove from tags list as well
        tags.remove(at: Int(index))
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
