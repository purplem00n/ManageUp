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
    
    var muBrain = MUBrain()
    
    @IBOutlet weak var date: UIDatePicker!
    @IBOutlet weak var tagEntryDropDown: DropDown!
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet weak var ttgTagView: TTGTextTagCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLayoutSubviews()
        
        date.date = muBrain.displayDate()
        date.timeZone = TimeZone.current
        
        ttgTagView.delegate = self
        
        for tag in muBrain.selectedEntry.tags {
            let textTag = TTGTextTag(content: TTGTextTagStringContent(text: tag), style: TTGTextTagStyle())
            ttgTagView.addTag(textTag)
        }
        ttgTagView.reload()
        
//        let tagStyle = TTGTextTagStyle()
//        tagStyle.backgroundColor = UIColor.white // not working

        muBrain.getAllUserTags(tagSelector: tagEntryDropDown)
        // set the drop down menu to display all tags
        tagEntryDropDown.optionArray = muBrain.allTags
        
        entryText.text = muBrain.selectedEntry.text
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        muBrain.handleSubmission(entryText: entryText.text, screen: self)
    }
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        // if tag is not an empty string, create a new tag item, add it to the tag viewer, and add it to the array of selected tags
        if let newTag = tagEntryDropDown.text, tagEntryDropDown.text != "" {
            let textTag = muBrain.createTextTag(tagText: newTag)
            if !muBrain.selectedTags.contains(newTag) {
                muBrain.selectedTags.append(newTag)
                ttgTagView.addTag(textTag)
                ttgTagView.reload()
            } else {
                muBrain.displayAlert(message: K.AlertMessage.duplicateTag, screen: self)
            }
            tagEntryDropDown.text = ""
        }
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        // remove tags on tap
        ttgTagView.removeTag(tag)
        ttgTagView.reload()
        // remove from tags list
        muBrain.selectedTags.remove(at: Int(index))
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        muBrain.logout(screen: self)
    }
}

