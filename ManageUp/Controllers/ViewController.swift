//
//  ViewController.swift
//  ManageUp
//
//  Created by Ariel Higuera on 7/21/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FSCalendar

class HomeViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var muBrain = MUBrain()
    @IBOutlet var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        // query database for dates with entries and reload calendar data
        muBrain.findDatesWithEntries(calendar)
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if UIDevice.current.orientation.isLandscape {
//            calendar.scope = .week
//            calendar.frame = CGRect(x: 50, y: 50, width: 700, height: 175)
//            calendar.reloadData()
//        } else {
//            calendar.scope = .month
//            calendar.reloadData()
//        }
//    }
    
    // tried this to address the problem of swiping and the date changing to 2073 or 2006
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//            calendar.reloadData()
//    }
    
    // also didn't work to fix the landscape/portrait issue.
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: {_ in
//            self.calendar.select(self.calendar.selectedDate)
//        }, completion: nil)
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        muBrain.selectedDate = calendar.selectedDate!
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateComponents = muBrain.convertDateToDateComponents(date: date)
        return muBrain.datesWithEntry[dateComponents] ?? 0
    }
    
    // let the segue send selected data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.searchSegue {
            if let searchViewController = segue.destination as? SearchViewController {
                searchViewController.muBrain = muBrain
            }
        }
        if segue.identifier == K.formSegue {
            if let formViewController = segue.destination as? FormViewController {
                formViewController.muBrain = muBrain
            }
        }
    }

    @IBAction func addEntryPressed(_ sender: UIButton) {
        muBrain.resetSelectedEntry()
        performSegue(withIdentifier: K.formSegue, sender: self)
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.searchSegue, sender: self)
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        muBrain.logout(screen: self)
    }
}

