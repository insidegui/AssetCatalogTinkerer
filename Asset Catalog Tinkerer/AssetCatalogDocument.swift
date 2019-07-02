//
//  Document.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import ACS

class AssetCatalogDocument: NSDocument {

    fileprivate var reader: AssetCatalogReader!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        if #available(OSX 10.12, *) {
            windowController.window?.tabbingIdentifier = "ACTWindow"
            windowController.window?.tabbingMode = .preferred
        }
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: windowController.window, queue: OperationQueue.main) { _ in
            if self.reader != nil { self.reader.cancelReading() }
        }
    }
    
    fileprivate var imagesViewController: ImagesViewController? {
        return windowControllers.first?.contentViewController as? ImagesViewController
    }

    override func read(from url: URL, ofType typeName: String) throws {
        reader = AssetCatalogReader(fileURL: url)
        reader.thumbnailSize = NSSize(width: 138.0, height: 138.0)
        
        reader.distinguishCatalogsFromThemeStores = Preferences.shared[.distinguishCatalogsAndThemeStores]
        reader.ignorePackedAssets = Preferences.shared[.ignorePackedAssets]
        
        reader.read(completionHandler: didFinishReading, progressHandler: updateProgress)
    }
    
    fileprivate func updateProgress(_ progress: Double) {
        imagesViewController?.loadProgress = progress
    }
    
    fileprivate func didFinishReading() {
        guard !reader.cancelled else { return }
        
        if let error = reader.error {
            imagesViewController?.error = error as NSError?
        } else {
            imagesViewController?.images = reader.images
        }
    }

}

