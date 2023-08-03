//
//  EntryViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 8/3/23.
//

import UIKit

class EntryViewController: UIViewController {
    
    var entry: Entry = Entry(user: "", text: "", tags: [], date: Date.now)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var textDisplay: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textDisplay.text = entry.text
        
        var dateString = formatDate(date: entry.date)
        dateLabel.text = dateString
        
        tagsLabel.text! = entry.tags.joined(separator: ", ")
        
    }
    
    func formatDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd, yyyy"
        return df.string(from:date)
    }

}
