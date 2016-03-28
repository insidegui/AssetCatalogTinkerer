//
//  GridLayout.swift
//  MacTube
//
//  Created by Guilherme Rambo on 20/01/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class GridLayout: NSCollectionViewFlowLayout {

    private struct Constants {
        static let itemWidth = CGFloat(150.0)
        static let itemHeight = CGFloat(150.0)
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
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> NSCollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        attributes?.zIndex = indexPath.item

        
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let layoutAttributesArray = super.layoutAttributesForElementsInRect(rect)
        
        for attr in layoutAttributesArray {
            guard let path = attr.indexPath else { continue }
            attr.zIndex = path.item
        }
        
        return layoutAttributesArray
    }
    
}
