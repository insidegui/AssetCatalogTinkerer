//
//  GridLayout.swift
//  MacTube
//
//  Created by Guilherme Rambo on 20/01/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class GridLayout: NSCollectionViewFlowLayout {

    fileprivate struct Constants {
        static let itemWidth = CGFloat(150.0)
        static let itemHeight = CGFloat(170.0)
        static let itemPadding = CGFloat(10.0)
    }
    
    override init() {
        super.init()
        
        self.itemSize = NSMakeSize(Constants.itemWidth, Constants.itemHeight)
        self.minimumInteritemSpacing = Constants.itemPadding
        self.minimumLineSpacing = Constants.itemPadding
        self.sectionInset = NSEdgeInsetsMake(Constants.itemPadding, Constants.itemPadding, Constants.itemPadding, Constants.itemPadding)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        attributes?.zIndex = (indexPath as NSIndexPath).item

        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let layoutAttributesArray = super.layoutAttributesForElements(in: rect)
        
        for attr in layoutAttributesArray {
            guard let path = attr.indexPath else { continue }
            attr.zIndex = (path as NSIndexPath).item
        }
        
        return layoutAttributesArray
    }
    
}
