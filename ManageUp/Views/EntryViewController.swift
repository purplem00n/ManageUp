//
//  EntryViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 8/3/23.
//

import UIKit

class EntryViewController: UIViewController {
    
    var muBrain: MUBrain = MUBrain()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var textDisplay: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate fields with selected entry if applicable
        textDisplay.text = muBrain.selectedEntry.text
        dateLabel.text = muBrain.formatDate(date: muBrain.selectedEntry.date, format: K.DateFormat.entryDate)
        tagsLabel.text! = muBrain.selectedEntry.tags.joined(separator: ", ")
        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        // take back to form controller, passing Entry data
        performSegue(withIdentifier: K.editSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.editSegue {
            if let formViewController = segue.destination as? FormViewController {
                formViewController.muBrain = muBrain
            }
        }
    }

}
