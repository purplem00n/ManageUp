//
//  SearchViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/25/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import iOSDropDown
import TTGTags

class SearchViewController: UIViewController, UISearchBarDelegate, TTGTextTagCollectionViewDelegate {
    
    //    let db = Firestore.firestore()
    
    var muBrain: MUBrain = MUBrain()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromDate: UIDatePicker!
    @IBOutlet weak var toDate: UIDatePicker!
    @IBOutlet weak var tagSelector: DropDown!
    let ttgTagView = TTGTextTagCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // sets timezone to the time zone of the device
        fromDate.timeZone = TimeZone.current
        toDate.timeZone = TimeZone.current
        
        // initialize tag view
        ttgTagView.frame = CGRect(x: 20, y: 275, width: view.frame.size.width, height: 50)
        ttgTagView.alignment = .left
        ttgTagView.delegate = self
        view.addSubview(ttgTagView)
        
        tagSelector.optionArray = muBrain.allTags
        
        muBrain.loadEntries(fromDate: fromDate, toDate: toDate, tableView: tableView)
        
        // TODO: fromDate displays today's date when it should show 010123 reflecting that it returns all entries
        fromDate.date = muBrain.selectedDate
        toDate.date = muBrain.selectedDate
        
        muBrain.getAllUserTags(tagSelector: tagSelector)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
//        if muBrain.selectedTags != [] {
//            muBrain.queryWithDateTags(tableView: tableView)
//        } else {
//            muBrain.queryEntriesWithDates(tableView: tableView)
//        }
        
        // how do I make it so the first queries only run when a tag or dates change, and this is the only function that actually runs when text did change.
        // then I think it doesn't make query every time the text changes, I'll just search throught the list of qualifying entries.
        muBrain.textSearch(searchText: searchText, tableView: tableView)
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {t
        
        muBrain.fromDateReset = fromDate.date
        muBrain.toDateReset = toDate.date
        
        if muBrain.selectedTags != [] {
            muBrain.queryWithDateTags(tableView: tableView)
        } else {
            muBrain.queryEntriesWithDates(tableView: tableView)
        }
    }
    
    
    // let the segue send selected vars data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.entrySegue {
            if let entryViewController = segue.destination as? EntryViewController {
                entryViewController.muBrain = muBrain
            }
        }
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        // remove tags on tap
        ttgTagView.removeTag(tag)
        ttgTagView.reload()
        // remove from tags list
        muBrain.selectedTags.remove(at: Int(index))
    }
    
    @IBAction func addTagPressed(_ sender: UIButton) {
        if let newTag = tagSelector.text, tagSelector.text != "" {
            if muBrain.allTags.contains(newTag) {
                let textTag = TTGTextTag(content: TTGTextTagStringContent(text: newTag), style: TTGTextTagStyle())
                ttgTagView.addTag(textTag)
                ttgTagView.reload()
                if !muBrain.selectedTags.contains(newTag) {
                    muBrain.selectedTags.append(newTag)
                }
                tagSelector.text = ""
            } else {
                muBrain.displayAlert(message: K.AlertMessage.tagError, screen: self)
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        muBrain.logout(screen: self)
    }
}

//populates table view
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muBrain.filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell")
        let dateString = muBrain.formatDate(date: muBrain.filteredEntries[indexPath.row].date, format: K.DateFormat.tableDate)
        cell?.detailTextLabel?.text = dateString
        cell?.textLabel?.text = String(muBrain.filteredEntries[indexPath.row].text.prefix(33))
        return cell!
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // this function is the action upon tapping on a table row
        muBrain.selectedEntry = muBrain.filteredEntries[indexPath.row]
        performSegue(withIdentifier: K.entrySegue, sender: self)
    }
}


