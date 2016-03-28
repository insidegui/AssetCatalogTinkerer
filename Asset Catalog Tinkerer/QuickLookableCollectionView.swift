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
    
    override func keyDown(theEvent: NSEvent) {
        // spacebar
        if theEvent.keyCode == 49 {
            showQuickLookPreview(self);
            return;
        }
        
        super.keyDown(theEvent)
    }
    
    func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        delegate?.collectionView?(self, didSelectItemsAtIndexPaths: indexPaths)
        
        guard QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.sharedPreviewPanel().visible else { return }
        
        writeSelectionToQuickLookPasteboard()
        QLPreviewPanel.sharedPreviewPanel().reloadData()
    }
    
    private lazy var quickLookHandler = QuickLookableCollectionViewPreviewHandler()
    
    @IBAction func showQuickLookPreview(sender: AnyObject) {
        guard selectionIndexPaths.count > 0 else { return }
        
        quickLookHandler.pasteboard = NSPasteboard(name: "CollectionViewQuickLook")
        quickLookHandler.collectionView = self
        
        let panel = QLPreviewPanel.sharedPreviewPanel()
        
        if (QLPreviewPanel.sharedPreviewPanelExists() && panel.visible) {
            panel.orderOut(self)
        } else {
            panel.makeKeyAndOrderFront(self)
            panel.reloadData()
        }
    }
    
    override func acceptsPreviewPanelControl(panel: QLPreviewPanel!) -> Bool {
        return true
    }
    
    override func beginPreviewPanelControl(panel: QLPreviewPanel!) {
        writeSelectionToQuickLookPasteboard()
        
        panel.delegate = quickLookHandler
        panel.dataSource = quickLookHandler
    }
    
    override func endPreviewPanelControl(panel: QLPreviewPanel!) {
        panel.delegate = nil
        panel.dataSource = nil
    }
    
    private func writeSelectionToQuickLookPasteboard() {
        quickLookHandler.pasteboard.clearContents()
        delegate?.collectionView?(self, writeItemsAtIndexPaths: selectionIndexPaths, toPasteboard: quickLookHandler.pasteboard)
    }
    
}

@objc private class QuickLookableCollectionViewPreviewHandler: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    var pasteboard: NSPasteboard!
    var collectionView: QuickLookableCollectionView!
    
    var previewItems: [NSURL] {
        guard let items = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else { return [] }
        
        return items.map { NSURL(fileURLWithPath: $0) }
    }
    
    @objc private func numberOfPreviewItemsInPreviewPanel(panel: QLPreviewPanel!) -> Int {
        return previewItems.count
    }
    
    @objc private func previewPanel(panel: QLPreviewPanel!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        guard previewItems.count > 0 else { return nil }
        
        return previewItems[index]
    }
    
    @objc private func previewPanel(panel: QLPreviewPanel!, handleEvent event: NSEvent!) -> Bool {
        if event.type == NSEventType.KeyDown {
            collectionView.keyDown(event)
            return true
        }
        
        return false
    }
    
    @objc private func previewPanel(panel: QLPreviewPanel!, sourceFrameOnScreenForPreviewItem item: QLPreviewItem!) -> NSRect {
        let combinedRect = collectionView.selectionIndexes.map { return collectionView.frameForItemAtIndex($0) }.reduce(NSZeroRect) { NSUnionRect($0, $1) }
        
        var preliminaryRect = collectionView.enclosingScrollView!.convertRect(combinedRect, toView: nil)
        preliminaryRect.origin.y += collectionView.enclosingScrollView!.contentView.bounds.origin.y
        let rect = collectionView.window?.convertRectToScreen(preliminaryRect)
        
        return rect ?? NSZeroRect
    }
    
}
