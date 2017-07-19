//
//  ViewController.swift
//  Ronchi
//
//  Created by James LeBeau on 6/12/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var AberrationsController: NSArrayController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    


}

extension NSViewController {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
}
