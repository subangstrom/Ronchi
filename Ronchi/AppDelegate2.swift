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


func defaultsObjectContext()->NSManagedObjectContext{
    
    
    // First load the Data Model
    // `momd` is important
    
    
    //This resource is the same name as your xcdatamodeld contained in your project
    guard let modelURL = Bundle.main.url(forResource: "Document", withExtension:"momd") else {
        fatalError("Error loading model from bundle")
    }
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
        fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    
    let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    moc.persistentStoreCoordinator = psc
    
    moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    let docURL = NSPersistentContainer.defaultDirectoryURL()
    let storeURL = docURL.appendingPathComponent( "UserDefaults.sqlite")
    
    let options = [NSSQLitePragmasOption:["journal_mode":"DELETE"]];
    
    do {
        try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
    } catch {
        fatalError("Error migrating store: \(error)")
    }
    
    return moc
    
    
}

