//
//  ImagesCollectionViewDataProvider.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers

extension NSUserInterfaceItemIdentifier {
    static let imageItemIdentifier = NSUserInterfaceItemIdentifier("ImageItemIdentifier")
}

class ImagesCollectionViewDataProvider: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate struct Constants {
        static let nibName = "ImageCollectionViewItem"

    }
    
    var collectionView: NSCollectionView! {
        didSet {
            collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.collectionViewLayout = GridLayout()
            
            let nib = NSNib(nibNamed: Constants.nibName, bundle: nil)
            collectionView.register(nib, forItemWithIdentifier: .imageItemIdentifier)
        }
    }
    
    var images = [[String: NSObject]]() {
        didSet {
            filteredImages = filterImagesWithCurrentSearchTerm()
            collectionView.reloadData()
        }
    }
    
    var searchTerm = "" {
        didSet {
            filteredImages = filterImagesWithCurrentSearchTerm()
            collectionView.reloadData()
        }
    }
    
    var filteredImages = [[String: NSObject]]()
    
    fileprivate func filterImagesWithCurrentSearchTerm() -> [[String: NSObject]] {
        guard !searchTerm.isEmpty else { return images }
        
        let predicate = NSPredicate(format: "name contains[cd] %@", searchTerm)
        return (images as NSArray).filtered(using: predicate) as! [[String: NSObject]]
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .imageItemIdentifier, for: indexPath) as! ImageCollectionViewItem
        
        item.image = filteredImages[(indexPath as NSIndexPath).item]
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    private func canPerformPasteboardOperation(at indexPath: IndexPath) -> Bool {
        assert(indexPath.section == 0, "Only a single section is supported for now")
        assert(indexPath.item < filteredImages.count, "Invalid item index")
        
        return indexPath.item < filteredImages.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        guard canPerformPasteboardOperation(at: indexPath) else { return nil }
        
        // TODO: Use correct file type/extension instead of hardcoding png.
        let fileExtension = "png"
        
        let provider: NSFilePromiseProvider
        
        if #available(macOS 11.0, *) {
            let typeIdentifier = UTType(filenameExtension: fileExtension)
            provider = NSFilePromiseProvider(fileType: typeIdentifier!.identifier, delegate: self)
        } else {
            let typeIdentifier =
            UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
            provider = NSFilePromiseProvider(fileType: typeIdentifier!.takeRetainedValue() as String, delegate: self)
        }
        
        provider.userInfo = self.filteredImages[indexPath.item]
        
        return provider
    }
    
    private lazy var filePromiseQueue = OperationQueue()
    
    private let copyQueue = DispatchQueue(label: "Copy", qos: .userInteractive)
    
    func generalPasteboardWriter(at indexPath: IndexPath) -> NSPasteboardWriting? {
        guard canPerformPasteboardOperation(at: indexPath) else { return nil }
        
        let image = filteredImages[indexPath.item]

        guard let filename = image["filename"] as? String else { return nil }
        guard let data = image["png"] as? Data else { return nil }
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(filename)

        do {
            try data.write(to: tempURL, options: .atomic)
            
            return tempURL as NSURL
        } catch {
            assertionFailure("Failed to write temporary URL for pasteboard: \(String(describing: error))")
            return nil
        }
    }
    
}

extension ImagesCollectionViewDataProvider: NSFilePromiseProviderDelegate {
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        guard let image = filePromiseProvider.userInfo as? [String: NSObject] else {
            return ""
        }
        
        guard let filename = image["filename"] as? String else { return "" }
        
        return filename
    }
    
    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue { filePromiseQueue }
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let image = filePromiseProvider.userInfo as? [String: NSObject] else {
            completionHandler(nil)
            return
        }
        
        guard let data = image["png"] as? Data else {
            completionHandler(nil)
            return
        }
        
        do {
            try data.write(to: url)
            
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
}
