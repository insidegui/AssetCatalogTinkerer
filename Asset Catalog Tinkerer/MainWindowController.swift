//
//  MainWindowController.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 28/05/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

  var isBackgroundShaded = false
  
    @IBOutlet weak var darkModeButton: NSButton!
    @IBOutlet weak var searchField: NSSearchField!

    override func awakeFromNib() {
        super.awakeFromNib()

        checkDarkMode()
    }
  
  private func checkDarkMode() {
      isBackgroundShaded = Preferences.shared[.startInDarkMode]
      updateDarkModeUI()
  }
  
    @IBAction func enableSearchField(_ sender: AnyObject?) {
        searchField.isEnabled = true
    }
    
    @IBAction func disableSearchField(_ sender: AnyObject?) {
        searchField.isEnabled = false
    }
  
    @IBAction func toggleBackground(_ sender: NSButton?) {
        isBackgroundShaded = !isBackgroundShaded
        updateDarkModeUI()
    }
  
    private func updateDarkModeUI() {
        darkModeButton.title = isBackgroundShaded ? "Dark" : "Light"
        darkModeButton.state = isBackgroundShaded ? NSOnState : NSOffState
        window?.backgroundColor = isBackgroundShaded ? .lightGray : .white
    }
}
