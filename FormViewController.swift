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
    
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var tagEntryDropDown: DropDown!
    @IBOutlet weak var entryText: UITextView!
    let ttgTagView = TTGTextTagCollectionView()
    
    let db = Firestore.firestore()
    
    //accept values from EntryViews here for editing
    var entryValue: Entry = Entry(user: (Auth.auth().currentUser?.email)!, id: "", text: "", tags: [], date: Date.now)
    var tags: [String] = []
    var selectedDate: Date = Date.now
    var textValue: String = ""
    
    var allTagsArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLayoutSubviews()
        
        // assign initial values to the UI: if empty, or if editing existing values
        tags = entryValue.tags
        entryText.text = entryValue.text
        
        let todayDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: Date.now)
        let entryValueDateComponents = Calendar.current.dateComponents([.month, .day, .year], from: entryValue.date)
        
        if entryValueDateComponents != todayDateComponents {
            date.date = entryValue.date
        } else {
            date.date = selectedDate
        }
            
            ttgTagView.frame = CGRect(x: 20, y: 148, width: view.frame.size.width, height: 150)
            ttgTagView.alignment = .left
            ttgTagView.delegate = self
            view.addSubview(ttgTagView)
            
            for tag in tags {
                let textTag = TTGTextTag(content: TTGTextTagStringContent(text: tag), style: TTGTextTagStyle())
                ttgTagView.addTag(textTag)
            }
            ttgTagView.reload()
            
            tagEntryDropDown.optionArray = allTagsArray
            
            date.timeZone = TimeZone.current
            
            getAllUserTags()
            
        }
        
        // can probably clean this up
        @IBAction func submitPressed(_ sender: UIButton) {
            if textValue == "" {
                displayAlert()
                return
            }
            if entryValue.id == "" {
                if let textBody = entryText.text, let user = Auth.auth().currentUser?.email {
                    db.collection(K.FStore.collectionName).document().setData([K.FStore.textField: textBody, K.FStore.dateField: date.date, K.FStore.userField: user, K.FStore.tagsField: tags]) { (error) in
                        if let e = error {
                            print(e)
                        } else {
                            self.performSegue(withIdentifier: K.submitSegue, sender: self)
                            print("Successfully saved data.")
                        }
                    }
                }
            } else {
                if let textBody = entryText.text, let user = Auth.auth().currentUser?.email {
                    db.collection(K.FStore.collectionName).document(entryValue.id).setData([K.FStore.textField: textBody, K.FStore.dateField: date.date, K.FStore.userField: user, K.FStore.tagsField: tags]) { (error) in
                        if let e = error {
                            print(e)
                        } else {
                            self.performSegue(withIdentifier: K.submitSegue, sender: self)
                            print("Successfully saved data.")
                        }
                    }
                }
            }
        }
        
        @IBAction func addTagPressed(_ sender: UIButton) {
            if let newTag = tagEntryDropDown.text, tagEntryDropDown.text != "" {
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
            // remove from tags list
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
    
    func displayAlert() {
        // Declare Alert message
        let dialogMessage = UIAlertController(title: "Error", message: "Please add text to your entry", preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
        })
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
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

