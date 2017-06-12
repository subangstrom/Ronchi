//
//  Preferences.swift
//  Ronchigram
//
//  Created by James LeBeau on 6/3/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Cocoa


class PreferencesController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    
//    var managedObjectContext: NSManagedObjectContext

    @IBOutlet var defaultsMO: NSManagedObjectContext!
    @IBOutlet var abController: NSArrayController!

    @IBOutlet var textfield: NSTextField!
    
    fileprivate enum AberrationDisplayProperty: String {
        case label      = "label"
        case cnma       = "cnma"
        case cnmb  = "cnmb"
    }

    var aberrations:[Aberration] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let defaultsMO = defaultsObjectContext()
        
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        _ = appDelegate.aberrations
        
        
        let aberrationsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Aberration")
        
        do {
           aberrations = try defaultsMO.fetch(aberrationsFetch) as! [Aberration]
//
//            for ab in fetchedAberrations{
//                print("\(ab.cnma)")
//            }
            
        } catch {
            fatalError("Failed to fetch aberrations: \(error)")
        }

    
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func addRemoveAberration(_ sender: Any) {
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        
        guard let propertyEnum = AberrationDisplayProperty(rawValue: identifier) else {return nil}
        
        let cellView = tableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView
        let textField = cellView.textField!
        
        let ab = aberrations[row]
            
            switch propertyEnum {
            case .label:
                textField.stringValue = ab.label!
                
            case .cnma:
                textField.floatValue = ab.cnma
                
            case .cnmb:
                textField.floatValue = ab.cnmb
            }
        
        return cellView
    }
    
    
      
    
}
