//
//  ProgressBar.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

public class ProgressBar: NSView {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    public var tintColor: NSColor? {
        didSet {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            progressLayer.backgroundColor = tintColor?.CGColor
            CATransaction.commit()
        }
    }
    
    public var progress: Double = 0.0 {
        didSet {
            let animated = oldValue < progress
            
            dispatch_async(dispatch_get_main_queue()) { self.updateProgressLayer(animated) }
        }
    }
    
    private var progressLayer: CALayer!
    
    private func commonInit() {
        guard progressLayer == nil else { return }
        
        wantsLayer = true
        layer = CALayer()
        
        progressLayer = CALayer()
        progressLayer.backgroundColor = tintColor?.CGColor
        progressLayer.frame = NSRect(x: 0.0, y: 0.0, width: 0.0, height: bounds.height)
        layer!.addSublayer(progressLayer)
        progressLayer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        
        updateProgressLayer()
    }
    
    private var widthForProgressLayer: CGFloat {
        return bounds.width * CGFloat(progress)
    }
    
    private func updateProgressLayer(animated: Bool = true) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.4 : 0.0)
        var frame = progressLayer.frame
        frame.size.width = widthForProgressLayer
        progressLayer.frame = frame
        
        if progress >= 0.99 {
            progressLayer.opacity = 0.0
        } else {
            progressLayer.opacity = 1.0
        }
        
        CATransaction.commit()
    }
    
}
