//
//  ViewController.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ImagesViewController: NSViewController {
    
    var loadProgress = 0.0 {
        didSet {
            progressBar.progress = loadProgress
        }
    }
    
    var error: NSError? = nil {
        didSet {
            
        }
    }
    
    private var dataProvider = ImagesCollectionViewDataProvider()
    
    var images = [[String: NSObject]]() {
        didSet {
            dataProvider.images = images
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        buildUI()
    }
    
    // MARK: - UI
    
    private lazy var progressBar: ProgressBar = {
        let p = ProgressBar(frame: NSZeroRect)
        
        p.translatesAutoresizingMaskIntoConstraints = false
        p.tintColor = NSColor(calibratedRed:0, green:0.495, blue:1, alpha:1)
        p.progress = 0.0
        
        return p
    }()
    
    private lazy var scrollView: NSScrollView = {
        let s = NSScrollView(frame: NSZeroRect)
        
        s.translatesAutoresizingMaskIntoConstraints = false
        s.hasVerticalScroller = true
        s.borderType = .NoBorder
        
        return s
    }()
    
    private lazy var collectionView: NSCollectionView = {
        let c = NSCollectionView(frame: NSZeroRect)
        
        c.selectable = true
        c.allowsMultipleSelection = true
        
        return c
    }()
    
    private lazy var exportProgressView: NSVisualEffectView = {
        let vfxView = NSVisualEffectView(frame: NSZeroRect)
        
        vfxView.translatesAutoresizingMaskIntoConstraints = false
        vfxView.material = .MediumLight
        vfxView.blendingMode = .WithinWindow
        
        let p = NSProgressIndicator(frame: NSZeroRect)
        
        p.translatesAutoresizingMaskIntoConstraints = false
        p.style = .SpinningStyle
        p.controlSize = .RegularControlSize
        p.sizeToFit()
        
        vfxView.addSubview(p)
        p.centerYAnchor.constraintEqualToAnchor(vfxView.centerYAnchor).active = true
        p.centerXAnchor.constraintEqualToAnchor(vfxView.centerXAnchor).active = true
        
        vfxView.alphaValue = 0.0
        vfxView.hidden = true
        p.startAnimation(nil)
        
        return vfxView
    }()
    
    private func buildUI() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        collectionView.frame = scrollView.bounds
        scrollView.documentView = collectionView
        
        dataProvider.collectionView = collectionView
        
        progressBar.frame = NSRect(x: 0.0, y: view.bounds.height - 3.0, width: view.bounds.width, height: 3.0)
        progressBar.heightAnchor.constraintEqualToConstant(3.0).active = true
        view.addSubview(progressBar)
        
        progressBar.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        progressBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        progressBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    }
    
    private func showExportProgress() {
        if exportProgressView.superview == nil {
            exportProgressView.frame = view.bounds
            view.addSubview(exportProgressView)
            exportProgressView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
            exportProgressView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
            exportProgressView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
            exportProgressView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        }
        
        exportProgressView.hidden = false
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.exportProgressView.animator().alphaValue = 1.0
            }, completionHandler: nil)
    }
    
    private func hideExportProgress() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.exportProgressView.animator().alphaValue = 0.0
            }, completionHandler: {
                self.exportProgressView.hidden = true
        })
    }
    
    // MARK: - Export
    
    @IBAction func exportAllImages(sender: NSMenuItem) {
        imagesToExport = images
        launchExportPanel()
    }
    
    @IBAction func exportSelectedImages(sender: NSMenuItem) {
        imagesToExport = collectionView.selectionIndexes.map { return self.images[$0] }
        launchExportPanel()
    }
    
    private var imagesToExport: [[String: NSObject]]?
    
    private func launchExportPanel() {
        guard let imagesToExport = imagesToExport else { return }
        
        let panel = NSOpenPanel()
        panel.prompt = "Export"
        panel.title = "Select a directory to export the images to"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        
        panel.beginSheetModalForWindow(view.window!) { result in
            guard result == 1 else { return }
            guard panel.URL != nil else { return }
            
            self.exportImages(imagesToExport, toDirectoryAtURL: panel.URL!)
        }
    }
    
    private func exportImages(images: [[String: NSObject]], toDirectoryAtURL URL: NSURL) {
        showExportProgress()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            images.forEach { image in
                guard var pathComponents = URL.pathComponents else { return }
                guard let filename = image["filename"] as? String else { return }
                
                pathComponents.append(filename)
                
                guard let pngData = image["png"] as? NSData else { return }
                
                let path = NSString.pathWithComponents(pathComponents) as String
                if !pngData.writeToFile(path, atomically: true) {
                    NSLog("ERROR: Unable to write \(filename) to \(path)")
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideExportProgress()
            }
        }
    }
    
    private enum MenuItemTags: Int {
        case ExportAllImages = 1001
        case ExportSelectedImages = 1002
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        guard let semanticMenuItem = MenuItemTags(rawValue: menuItem.tag) else {
            return super.validateMenuItem(menuItem)
        }
        
        switch semanticMenuItem {
        case .ExportAllImages:
            return images.count > 0
        case .ExportSelectedImages:
            return collectionView.selectionIndexes.count > 0
        }
    }


}

