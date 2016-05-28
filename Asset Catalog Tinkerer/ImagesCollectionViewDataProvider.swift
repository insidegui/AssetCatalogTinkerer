//
//  ImagesCollectionViewDataProvider.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ImagesCollectionViewDataProvider: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    private struct Constants {
        static let nibName = "ImageCollectionViewItem"
        static let imageItemIdentifier = "ImageItemIdentifier"
    }
    
    var collectionView: NSCollectionView! {
        didSet {
            collectionView.setDraggingSourceOperationMask(.Copy, forLocal: false)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.collectionViewLayout = GridLayout()
            
            let nib = NSNib(nibNamed: Constants.nibName, bundle: nil)
            collectionView.registerNib(nib, forItemWithIdentifier: Constants.imageItemIdentifier)
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
    
    private func filterImagesWithCurrentSearchTerm() -> [[String: NSObject]] {
        guard !searchTerm.isEmpty else { return images }
        
        let predicate = NSPredicate(format: "name contains[cd] %@", searchTerm)
        return (images as NSArray).filteredArrayUsingPredicate(predicate) as! [[String: NSObject]]
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier(Constants.imageItemIdentifier, forIndexPath: indexPath) as! ImageCollectionViewItem
        
        item.image = filteredImages[indexPath.item]
        
        return item
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(collectionView: NSCollectionView, writeItemsAtIndexPaths indexPaths: Set<NSIndexPath>, toPasteboard pasteboard: NSPasteboard) -> Bool {
        pasteboard.clearContents()
        
        let images: [String?] = indexPaths.map { indexPath in
            let index = indexPath.item
            
            guard let filename = self.filteredImages[index]["filename"] as? String else { return nil }
            guard let data = self.filteredImages[index]["png"] as? NSData else { return nil }
            let tempURL = NSURL(fileURLWithPath: "\(NSTemporaryDirectory())\(filename)")
            
            guard data.writeToURL(tempURL, atomically: true) else { return nil }
            
            return tempURL.path
        }
        
        let validImages: [String] = images.filter { $0 != nil }.map { $0! }
        
        pasteboard.setPropertyList(validImages, forType: NSFilenamesPboardType)
        
        return true
    }
    
}