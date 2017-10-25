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
            if loadProgress >= 0.99 && error == nil {
                hideStatus()
                showSpinner()
            }
        }
    }
    
    var error: NSError? = nil {
        didSet {
            guard let error = error else { return }
            
            loadProgress = 1.0
            showStatus(error.localizedDescription)
            
            tellWindowControllerToDisableSearchField()
        }
    }
    
    fileprivate var dataProvider = ImagesCollectionViewDataProvider()
    
    var images = [[String: NSObject]]() {
        didSet {
            loadProgress = 1.0
            dataProvider.images = images
            hideSpinner()
            
            tellWindowControllerToEnableSearchField()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        buildUI()
        showStatus("Extracting Images...")
    }
    
    // MARK: - UI
    
    fileprivate lazy var progressBar: ProgressBar = {
        let p = ProgressBar(frame: NSZeroRect)
        
        p.translatesAutoresizingMaskIntoConstraints = false
        p.tintColor = NSColor(calibratedRed:0, green:0.495, blue:1, alpha:1)
        p.progress = 0.0
        
        return p
    }()
    
    fileprivate lazy var spinner: NSProgressIndicator = {
        let p = NSProgressIndicator(frame: NSZeroRect)
        
        p.translatesAutoresizingMaskIntoConstraints = false
        p.controlSize = .regular
        p.style = .spinningStyle
        p.isDisplayedWhenStopped = false
        p.isIndeterminate = true
        
        return p
    }()
    
    fileprivate lazy var statusLabel: NSTextField = {
        let l = NSTextField(frame: NSZeroRect)
        
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isBordered = false
        l.isBezeled = false
        l.isEditable = false
        l.isSelectable = false
        l.drawsBackground = false
        l.font = NSFont.systemFont(ofSize: 12.0, weight: NSFontWeightMedium)
        l.textColor = NSColor.secondaryLabelColor
        l.lineBreakMode = .byTruncatingTail
        
        l.alphaValue = 0.0
        
        return l
    }()
    
    fileprivate lazy var scrollView: NSScrollView = {
        let s = NSScrollView(frame: NSZeroRect)

        s.translatesAutoresizingMaskIntoConstraints = false
        s.hasVerticalScroller = true
        s.borderType = .noBorder
      
        return s
    }()
    
    fileprivate lazy var collectionView: QuickLookableCollectionView = {
        let c = QuickLookableCollectionView(frame: NSZeroRect)
        
        c.isSelectable = true
        c.allowsMultipleSelection = true
        c.backgroundColors = [.clear]
      
        return c
    }()
    
    fileprivate lazy var exportProgressView: NSVisualEffectView = {
        let vfxView = NSVisualEffectView(frame: NSZeroRect)
        
        vfxView.translatesAutoresizingMaskIntoConstraints = false
        vfxView.material = .mediumLight
        vfxView.blendingMode = .withinWindow
        
        let p = NSProgressIndicator(frame: NSZeroRect)
        
        p.translatesAutoresizingMaskIntoConstraints = false
        p.style = .spinningStyle
        p.controlSize = .regular
        p.sizeToFit()
        
        vfxView.addSubview(p)
        p.centerYAnchor.constraint(equalTo: vfxView.centerYAnchor).isActive = true
        p.centerXAnchor.constraint(equalTo: vfxView.centerXAnchor).isActive = true
        
        vfxView.alphaValue = 0.0
        vfxView.isHidden = true
        p.startAnimation(nil)
        
        return vfxView
    }()
    
    fileprivate func showSpinner() {
        if spinner.superview == nil {
            view.addSubview(spinner)
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        spinner.startAnimation(nil)
    }
    
    fileprivate func hideSpinner() {
        spinner.stopAnimation(nil)
    }
    
    fileprivate func buildUI() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        collectionView.frame = scrollView.bounds
        scrollView.documentView = collectionView
        
        dataProvider.collectionView = collectionView
        
        progressBar.frame = NSRect(x: 0.0, y: view.bounds.height - 3.0, width: view.bounds.width, height: 3.0)
        progressBar.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
        view.addSubview(progressBar)
        
        progressBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func showExportProgress() {
        tellWindowControllerToDisableSearchField()
        
        if exportProgressView.superview == nil {
            exportProgressView.frame = view.bounds
            view.addSubview(exportProgressView)
            exportProgressView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            exportProgressView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            exportProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            exportProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        exportProgressView.isHidden = false
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.exportProgressView.animator().alphaValue = 1.0
            }, completionHandler: nil)
    }
    
    fileprivate func hideExportProgress() {
        tellWindowControllerToEnableSearchField()
        
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.exportProgressView.animator().alphaValue = 0.0
            }, completionHandler: {
                self.exportProgressView.isHidden = true
        })
    }
    
    fileprivate func showStatus(_ status: String) {
        if statusLabel.superview == nil {
            view.addSubview(statusLabel)
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        statusLabel.stringValue = status
        statusLabel.isHidden = false
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.statusLabel.animator().alphaValue = 1.0
            }, completionHandler: nil)
    }
    
    fileprivate func hideStatus() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            self.statusLabel.animator().alphaValue = 0.0
            }, completionHandler: {
                self.statusLabel.isHidden = true
        })
    }
    
    @IBAction func search(_ sender: NSSearchField) {
        dataProvider.searchTerm = sender.stringValue
        
        if dataProvider.filteredImages.count == 0 {
            showStatus("No images found for \"\(dataProvider.searchTerm)\"")
        } else {
            hideStatus()
        }
    }
    
    fileprivate func tellWindowControllerToEnableSearchField() {
        NSApp.sendAction(#selector(MainWindowController.enableSearchField(_:)), to: nil, from: self)
    }
    
    fileprivate func tellWindowControllerToDisableSearchField() {
        NSApp.sendAction(#selector(MainWindowController.disableSearchField(_:)), to: nil, from: self)
    }
    
    // MARK: - Export
    
    func copy(_ sender: AnyObject) {
        guard collectionView.selectionIndexPaths.count > 0 else { return }
        
        _ = dataProvider.collectionView(collectionView, writeItemsAt: collectionView.selectionIndexPaths, to: NSPasteboard.general())
    }
    
    @IBAction func exportAllImages(_ sender: NSMenuItem) {
        imagesToExport = dataProvider.filteredImages
        launchExportPanel()
    }
    
    @IBAction func exportSelectedImages(_ sender: NSMenuItem) {
        imagesToExport = collectionView.selectionIndexes.map { return self.dataProvider.filteredImages[$0] }
        launchExportPanel()
    }
    
    fileprivate var imagesToExport: [[String: NSObject]]?
    
    fileprivate func launchExportPanel() {
        guard let imagesToExport = imagesToExport else { return }
        
        let panel = NSOpenPanel()
        panel.prompt = "Export"
        panel.title = "Select a directory to export the images to"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        
        panel.beginSheetModal(for: view.window!) { result in
            guard result == 1 else { return }
            guard panel.url != nil else { return }
            
            self.exportImages(imagesToExport, toDirectoryAt: panel.url!)
        }
    }
    
    fileprivate func exportImages(_ images: [[String: NSObject]], toDirectoryAt url: URL) {
        showExportProgress()
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            images.forEach { image in
                guard let filename = image["filename"] as? String else { return }
                
                var pathComponents = url.pathComponents
                
                pathComponents.append(filename)
                
                guard let pngData = image["png"] as? Data else { return }
                
                let path = NSString.path(withComponents: pathComponents) as String
                if !((try? pngData.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) {
                    NSLog("ERROR: Unable to write \(filename) to \(path)")
                }
            }
            
            DispatchQueue.main.async {
                self.hideExportProgress()
            }
        }
    }
    
    fileprivate enum MenuItemTags: Int {
        case exportAllImages = 1001
        case exportSelectedImages = 1002
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if NSStringFromSelector(menuItem.action!) == "copy:" {
            return collectionView.selectionIndexPaths.count > 0
        }
        
        guard let semanticMenuItem = MenuItemTags(rawValue: menuItem.tag) else {
            return false
        }
        
        switch semanticMenuItem {
        case .exportAllImages:
            return images.count > 0
        case .exportSelectedImages:
            return collectionView.selectionIndexes.count > 0
        }
    }


}

