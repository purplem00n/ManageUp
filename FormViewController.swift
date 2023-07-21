//
//  FormViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit

class FormViewController: UIViewController {

    
    @IBOutlet weak var entryText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        print(entryText.text!)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
