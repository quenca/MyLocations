//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 13/06/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    // Setting the status bar to white color 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
