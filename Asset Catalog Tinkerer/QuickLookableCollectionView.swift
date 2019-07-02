//
//  QuickLookableCollectionView.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 28/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import Quartz

class QuickLookableCollectionView: NSCollectionView {
    
    override func keyDown(with theEvent: NSEvent) {
        // spacebar
        if theEvent.keyCode == 49 {
            showQuickLookPreview(self);
            return;
        }
        
        super.keyDown(with: theEvent)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<IndexPath>) {
        delegate?.collectionView?(self, didSelectItemsAt: indexPaths)
        
        guard QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible else { return }
        
        writeSelectionToQuickLookPasteboard()
        QLPreviewPanel.shared().reloadData()
    }
    
    fileprivate lazy var quickLookHandler = QuickLookableCollectionViewPreviewHandler()
    
    @IBAction func showQuickLookPreview(_ sender: AnyObject) {
        guard selectionIndexPaths.count > 0 else { return }
        
        quickLookHandler.pasteboard = NSPasteboard(name: NSPasteboard.Name(rawValue: "CollectionViewQuickLook"))
        quickLookHandler.collectionView = self
        
        let panel = QLPreviewPanel.shared()
        
        if (QLPreviewPanel.sharedPreviewPanelExists() && (panel?.isVisible)!) {
            panel?.orderOut(self)
        } else {
            panel?.makeKeyAndOrderFront(self)
            panel?.reloadData()
        }
    }
    
    override func acceptsPreviewPanelControl(_ panel: QLPreviewPanel!) -> Bool {
        return true
    }
    
    override func beginPreviewPanelControl(_ panel: QLPreviewPanel!) {
        writeSelectionToQuickLookPasteboard()
        
        panel.delegate = quickLookHandler
        panel.dataSource = quickLookHandler
    }
    
    override func endPreviewPanelControl(_ panel: QLPreviewPanel!) {
        panel.delegate = nil
        panel.dataSource = nil
    }
    
    fileprivate func writeSelectionToQuickLookPasteboard() {
        quickLookHandler.pasteboard.clearContents()
        _ = delegate?.collectionView?(self, writeItemsAt: selectionIndexPaths, to: quickLookHandler.pasteboard)
    }
    
}

@objc private class QuickLookableCollectionViewPreviewHandler: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    var pasteboard: NSPasteboard!
    var collectionView: QuickLookableCollectionView!
    
    var previewItems: [URL] {
        guard let items = pasteboard.filenamesPropertyList() else { return [] }
        
        return items.map { URL(fileURLWithPath: $0) }
    }
    
    @objc fileprivate func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return previewItems.count
    }
    
    @objc fileprivate func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        guard previewItems.count > 0 else { return nil }
        
        return previewItems[index] as QLPreviewItem?
    }
    
    @objc fileprivate func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if event.type == .keyDown {
            collectionView.keyDown(with: event)
            return true
        }
        
        return false
    }
    
    @objc fileprivate func previewPanel(_ panel: QLPreviewPanel!, sourceFrameOnScreenFor item: QLPreviewItem!) -> NSRect {
        let combinedRect = collectionView.selectionIndexes.map { return collectionView.frameForItem(at: $0) }.reduce(NSZeroRect) { NSUnionRect($0, $1) }
        
        var preliminaryRect = collectionView.enclosingScrollView!.convert(combinedRect, to: nil)
        preliminaryRect.origin.y += collectionView.enclosingScrollView!.contentView.bounds.origin.y
        let rect = collectionView.window?.convertToScreen(preliminaryRect)
        
        return rect ?? NSZeroRect
    }
    
}
