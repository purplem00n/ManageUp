//
//  Constants.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/26/23.
//

import UIKit

struct K {
    static let registerSegue = "RegisterToHome"
    static let loginSegue = "LoginToHome"
    static let formSegue = "HomeToForm"
    static let searchSegue = "HomeToSearch"
    static let entrySegue = "SearchToEntry"
    static let editSegue = "EntryToForm"
    static let submitSegue = "FormToHome"
    
    struct FStore {
        static let collectionName = "entries"
        static let userCollection = "users"
        static let userField = "user"
        static let textField = "text"
        static let dateField = "date"
        static let tagsField = "tags"
        
    }
    
    struct AlertMessage {
        static let errorTitle = "Error"
        static let tagError = "You must choose an existing tag"
        static let noTextError = "Please add text to your entry"
        static let duplicateTag = "This tag has already been added"
    }
    
    struct DateFormat {
        static let tableDate = "MMMM dd"
        static let entryDate = "MMMM dd, yyyy"
    }
    
//    struct Colors {
//        let blue = UIColor.blue
//        let red = UIColor.red
//        let purple = UIColor.purple
//        let orange = UIColor.orange
//    }
    
}
