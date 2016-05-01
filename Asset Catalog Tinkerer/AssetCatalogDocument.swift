//
//  Document.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class AssetCatalogDocument: NSDocument {

    private var reader: AssetCatalogReader!
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        NSNotificationCenter.defaultCenter().addObserverForName(NSWindowWillCloseNotification, object: windowController.window, queue: NSOperationQueue.mainQueue()) { _ in
            if self.reader != nil { self.reader.cancelReading() }
        }
    }
    
    private var imagesViewController: ImagesViewController! {
        return windowControllers[0].contentViewController as! ImagesViewController
    }

    override func readFromURL(url: NSURL, ofType typeName: String) throws {
        reader = AssetCatalogReader(fileURL: url)
        reader.thumbnailSize = NSSize(width: 138.0, height: 138.0)
        
        reader.readWithCompletionHandler(didFinishReading, progressHandler: updateProgress)
    }
    
    private func updateProgress(progress: Double) {
        imagesViewController.loadProgress = progress
    }
    
    private func didFinishReading() {
        guard !reader.cancelled else { return }
        
        if let error = reader.error {
            imagesViewController.error = error
        } else {
            imagesViewController.images = reader.images
        }
    }

}

