//
//  ImageCollectionViewItem.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

private extension NSColor {
  static let background = NSColor.clear
  static let selectedBackground = NSColor(calibratedRed:0, green:0.496, blue:1, alpha:1)
}

class ImageCollectionViewItem: NSCollectionViewItem {

  @IBOutlet weak var nameLabel: NSTextField!
  @IBOutlet weak var catalogImageBox: NSBox!
  @IBOutlet weak var catalogImageView: NSImageView!
  
  var image: [String: NSObject]? {
        didSet {
            updateUI()
        }
    }
    
    override var isSelected: Bool {
        didSet {
          catalogImageBox.fillColor = isSelected ? .selectedBackground : .background
          catalogImageBox.borderWidth = isSelected ? 0 : 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        updateUI()
    }
    
    fileprivate func updateUI() {
        guard let imageData = image , isViewLoaded else { return }
        guard let image = imageData["thumbnail"] as? NSImage else { return }
        let name = imageData["name"] as! String
        let filename = imageData["filename"] as! String
        
        catalogImageView.image = image
        nameLabel.stringValue = name
        view.toolTip = filename
    }
}
