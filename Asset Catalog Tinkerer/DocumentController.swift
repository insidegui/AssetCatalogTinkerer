//
//  DocumentController.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 28/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class DocumentController: NSDocumentController {

    override func newDocument(sender: AnyObject?) {
        // the app doesn't support creating new documents
    }
    
    override func saveAllDocuments(sender: AnyObject?) {
        // the app doesn't support saving documents
    }
    
    override func runModalOpenPanel(openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        openPanel.allowedFileTypes = ["car", "app", "framework", "bundle", "plugin"]
        openPanel.treatsFilePackagesAsDirectories = true
        
        return openPanel.runModal()
    }
    
}
