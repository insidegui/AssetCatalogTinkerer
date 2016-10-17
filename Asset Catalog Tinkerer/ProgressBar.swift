//
//  ProgressBar.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa

open class ProgressBar: NSView {

    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        commonInit()
    }
    
    open var tintColor: NSColor? {
        didSet {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            progressLayer.backgroundColor = tintColor?.cgColor
            CATransaction.commit()
        }
    }
    
    open var progress: Double = 0.0 {
        didSet {
            let animated = oldValue < progress
            
            DispatchQueue.main.async { self.updateProgressLayer(animated) }
        }
    }
    
    fileprivate var progressLayer: CALayer!
    
    fileprivate func commonInit() {
        guard progressLayer == nil else { return }
        
        wantsLayer = true
        layer = CALayer()
        
        progressLayer = CALayer()
        progressLayer.backgroundColor = tintColor?.cgColor
        progressLayer.frame = NSRect(x: 0.0, y: 0.0, width: 0.0, height: bounds.height)
        layer!.addSublayer(progressLayer)
        progressLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        updateProgressLayer()
    }
    
    fileprivate var widthForProgressLayer: CGFloat {
        return bounds.width * CGFloat(progress)
    }
    
    fileprivate func updateProgressLayer(_ animated: Bool = true) {
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
