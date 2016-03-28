//
//  ImageCollectionViewItem.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

class ImageCollectionViewItem: NSCollectionViewItem {

    var image: [String: NSObject]? {
        didSet {
            updateUI()
        }
    }
    
    private struct Colors {
        static let background = NSColor.whiteColor()
        static let border = NSColor(calibratedWhite: 0.9, alpha: 1.0)
        static let selectedBackground = NSColor(calibratedRed:0, green:0.496, blue:1, alpha:1)
        static let selectedBorder = NSColor(calibratedRed:0.019, green:0.316, blue:0.687, alpha:1)
        static let text = NSColor(calibratedRed:0, green:0.496, blue:1, alpha:1)
        static let selectedText = NSColor.whiteColor()
    }
    
    override var selected: Bool {
        didSet {
            view.layer?.backgroundColor = selected ? Colors.selectedBackground.CGColor : Colors.background.CGColor
            view.layer?.borderColor = selected ? Colors.selectedBorder.CGColor : Colors.border.CGColor
            nameLabel.textColor = selected ? Colors.selectedText : Colors.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        updateUI()
    }
    
    private lazy var catalogImageView: NSImageView = {
        let iv = NSImageView(frame: NSZeroRect)
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.imageFrameStyle = .None
        iv.imageScaling = .ScaleProportionallyDown
        iv.imageAlignment = .AlignCenter
        
        return iv
    }()
    
    private lazy var nameLabel: NSTextField = {
        let l = NSTextField(frame: NSZeroRect)
        
        l.translatesAutoresizingMaskIntoConstraints = false
        l.bordered = false
        l.bezeled = false
        l.editable = false
        l.selectable = false
        l.drawsBackground = false
        l.font = NSFont.systemFontOfSize(11.0, weight: NSFontWeightMedium)
        l.textColor = Colors.text
        l.lineBreakMode = .ByTruncatingMiddle
        
        return l
    }()
    
    private func buildUI() {
        guard catalogImageView.superview == nil else { return }
        
        view.wantsLayer = true
        view.layer = CALayer()
        
        catalogImageView.frame = view.bounds
        view.addSubview(catalogImageView)
        
        catalogImageView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        catalogImageView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        catalogImageView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        catalogImageView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        view.layer!.borderWidth = 1.0
        view.layer!.borderColor = Colors.border.CGColor
        view.layer!.cornerRadius = 4.0
        
        view.addSubview(nameLabel)
        nameLabel.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -2.0).active = true
        nameLabel.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        nameLabel.widthAnchor.constraintLessThanOrEqualToAnchor(view.widthAnchor, multiplier: 1.0, constant: -12.0)
    }
    
    private func updateUI() {
        guard let imageData = image where viewLoaded else { return }
        guard let image = imageData["thumbnail"] as? NSImage else { return }
        let name = imageData["name"] as! String
        let filename = imageData["filename"] as! String
        
        catalogImageView.image = image
        nameLabel.stringValue = name
        view.toolTip = filename
    }
    
}
