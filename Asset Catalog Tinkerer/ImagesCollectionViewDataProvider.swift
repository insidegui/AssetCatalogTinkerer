//
//  ImagesCollectionViewDataProvider.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ImagesCollectionViewDataProvider: NSObject, NSCollectionViewDataSource {
    
    private struct Constants {
        static let nibName = "ImageCollectionViewItem"
        static let imageItemIdentifier = "ImageItemIdentifier"
    }
    
    var collectionView: NSCollectionView! {
        didSet {
            collectionView.dataSource = self
            
            collectionView.collectionViewLayout = GridLayout()
            
            let nib = NSNib(nibNamed: Constants.nibName, bundle: nil)
            collectionView.registerNib(nib, forItemWithIdentifier: Constants.imageItemIdentifier)
        }
    }
    
    var images = [[String: NSObject]]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItemWithIdentifier(Constants.imageItemIdentifier, forIndexPath: indexPath) as! ImageCollectionViewItem
        
        item.image = images[indexPath.item]
        
        return item
    }
    
    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
}