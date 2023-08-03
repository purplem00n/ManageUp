//
//  EntryViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 8/3/23.
//

import UIKit

class EntryViewController: UIViewController {
    
    var entry: Entry = Entry(user: "", id: "", text: "", tags: [], date: Date.now)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var textDisplay: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textDisplay.text = entry.text
        
        let dateString = formatDate(date: entry.date)
        dateLabel.text = dateString
        
        tagsLabel.text! = entry.tags.joined(separator: ", ")
        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        // take back to form controller, passing Entry data
        performSegue(withIdentifier: K.editSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.editSegue {
            if let entryViewController = segue.destination as? FormViewController {
                entryViewController.entryValue = entry
            }
        }
    }
    
    
    func formatDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM dd, yyyy"
        return df.string(from:date)
    }

}
