//
//  DocumentController.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 28/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

    override func newDocument(_ sender: Any?) {
        // the app doesn't support creating new documents
    }
    
    override func saveAllDocuments(_ sender: Any?) {
        // the app doesn't support saving documents
    }
    
    private func makeSettingsView() -> NSView? {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateController(withIdentifier: "prefs") as? NSViewController else {
            return nil
        }
        
        return viewController.view
    }

    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        openPanel.allowedFileTypes = ["car", "app", "framework", "bundle", "plugin"]
        openPanel.treatsFilePackagesAsDirectories = true
        openPanel.accessoryView = makeSettingsView()

        return openPanel.runModal().rawValue
    }

}
