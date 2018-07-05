//
//  Functions.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 24/05/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import Foundation

// The annotation @escaping is necessary for closures that are not performed immediately
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

// Get the directory of your date files
let applicationDocumentDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let CoreDataSaveFailedNotification =
    Notification.Name(rawValue: "CoreDataSaveFailedNotification")

// Handling fatal Core Data errors
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: CoreDataSaveFailedNotification, object: nil)
}
