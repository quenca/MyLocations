//
//  String+AddText.swift
//  MyLocations
//
//  Created by Gustavo Quenca on 11/06/18.
//  Copyright © 2018 Quenca. All rights reserved.
//

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
