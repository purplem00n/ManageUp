//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var entries: [Entry] = [
        Entry(user:"1@2.com", date: Date.now, text: "This is a test entry", tags:["success", "capstone"]),
        Entry(user:"1@2.com", date: Date.now, text: "Add entries to table view", tags: ["success", "organization"]),
        Entry(user: "1@2.com", date: Date.now, text: "Complete another story!", tags: ["accomplishment"])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
        try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
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

//populates table view
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        cell?.textLabel?.text = entries[indexPath.row].text
        return cell!
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: this function is where I can tell it what to do when the user clicks on an entry listed in the table
        print(indexPath.row)
    }
}
