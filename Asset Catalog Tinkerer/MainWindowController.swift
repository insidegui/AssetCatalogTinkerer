//
//  MainWindowController.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 28/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    @IBOutlet weak var searchField: NSSearchField!
    
    @IBAction func enableSearchField(_ sender: AnyObject?) {
        searchField.isEnabled = true
    }
    
    @IBAction func disableSearchField(_ sender: AnyObject?) {
        searchField.isEnabled = false
    }
    
}
