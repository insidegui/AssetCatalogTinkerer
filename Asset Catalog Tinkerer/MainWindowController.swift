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
    
    @IBAction func enableSearchField(sender: AnyObject?) {
        searchField.enabled = true
    }
    
    @IBAction func disableSearchField(sender: AnyObject?) {
        searchField.enabled = false
    }
    
}
