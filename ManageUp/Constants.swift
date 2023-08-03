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
    
    struct FStore {
        static let collectionName = "entries"
        static let userField = "user"
        static let textField = "text"
        static let dateField = "date"
        static let tagsField = "tags"
        
    }
    
//    struct Colors {
//        let blue = UIColor.blue
//        let red = UIColor.red
//        let purple = UIColor.purple
//        let orange = UIColor.orange
//    }
    
}
