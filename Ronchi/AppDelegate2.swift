//
//  AppDelegate.swift
//  Ronchigram
//
//  Created by James LeBeau on 5/19/17.
//  Copyright © 2017 The Handsome Microscopist. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    
    var moc: NSManagedObjectContext?
    
    let aberrations: [[String : Any]] = {
        
        
        let c3 = ["label":"3rd order spherical", "n":3, "m":0] as [String : Any]
        let c5 = ["label":"5rd order spherical", "n":5, "m":0] as [String : Any]
        
        
        let a1 = ["label":"2-fold astigmatism", "n":1, "m":2] as [String : Any]
        let a2 = ["label":"3-fold astigmatism", "n":2, "m":3] as [String : Any]
        let a3 = ["label":"4-fold astigmatism", "n":3, "m":4] as [String : Any]
        
        return [a1, a2, a3, c3, c5]
    }()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup initial defaults
        
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        // Should also check to see if file exists or needs updating
        
        if true  {
            
           
            moc = defaultsObjectContext()
            
            

            
            
            
            
            for ab in aberrations{
                
                let entityDescription = NSEntityDescription.entity(forEntityName: "Aberration", in: moc!)
                let defaultAb = NSManagedObject(entity: entityDescription!, insertInto: moc) as! Aberration
                
                defaultAb.setValuesForKeys(ab)

                
            }
            
            
            
            do {
                try moc?.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }

            
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        

        
        
        
        
    
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    




}




