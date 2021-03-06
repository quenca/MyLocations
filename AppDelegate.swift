//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 07/05/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // This is the code you need to load the data model that you’ve defined earlier, and to connect it to an SQLite data store.
    lazy var persistentContainer: NSPersistentContainer = {
        // Create an NSPersistentStoreCoordinator object. This object is in charge of the SQLite database.
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: {
        storeDescription, error in
        if let error = error {
        fatalError("Could load data store: \(error)")
        }
        })
        return container
        }()
    
    // Add another property to get the NSManagedObjectContext from the persistent container
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    
    
    // This changes the “bar tint” or background color of all navigation bars and tab bars in the app to black in one fell swoop. It also sets the color of the navigation bar’s title label to white and applies the tint color to the tab bar
    func customizeAppearance() {
       UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        
        UITabBar.appearance().barTintColor = UIColor.black
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor
        
    }
    
    
    // MARK:- Helper methods
    func listenForFatalCoreDataNotifications() {
        // Tell NotificationCenter that you want to be notified whenever a CoreDataSaveFailedNotification is posted
        NotificationCenter.default.addObserver(
            forName: CoreDataSaveFailedNotification,
            object: nil, queue: OperationQueue.main,
            using: { notification in
                // Set up the error message to display
                let message = """
                There was a fatal error in the app and it cannot continue.

                Press OK to terminate the app. Sorry for the inconvenience.
                """
                // Create a UIAlertController to show the error message and use the multiline string from earlier as the message.
                let alert = UIAlertController(
                    title: "Internal Error", message: message,
                    preferredStyle: .alert)
                
                // Add an action for the alert’s OK button.
                let action = UIAlertAction(title: "OK",
                                           style: .default) { _ in
                                            let exception = NSException(
                                                name: NSExceptionName.internalInconsistencyException,
                                                reason: "Fatal Core Data error", userInfo: nil)
                                            exception.raise()
                }
                alert.addAction(action)
                // To show the alert with present(animated:completion:) you need a view controller that is currently visible.
                let tabController = self.window!.rootViewController!
                tabController.present(alert, animated: true,
                                      completion: nil)
        })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        customizeAppearance()
        
        // Override point for customization after application launch.
        let tabController = window!.rootViewController as! UITabBarController
        if let tabViewControllers = tabController.viewControllers {
        
                // First tab
                var navController = tabViewControllers[0]
                    as! UINavigationController
                let controller1 = navController.viewControllers.first
                    as! CurrentLocationViewController
            controller1.managedObjectContext = managedObjectContext
                // Second tab
                navController = tabViewControllers[1]
                    as! UINavigationController
                let controller2 = navController.viewControllers.first
                    as! LocationsViewController
            controller2.managedObjectContext = managedObjectContext
            // Third tab
            navController = tabViewControllers[2] as! UINavigationController
            let controller3 = navController.viewControllers.first
                as! MapViewController
            controller3.managedObjectContext = managedObjectContext
            
        }
        // Print the document Diretory
        print(applicationDocumentDirectory)
        listenForFatalCoreDataNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

