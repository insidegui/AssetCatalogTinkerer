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
        
        panel.dataSource = quickLookHandler
    }
    
    override func endPreviewPanelControl(panel: QLPreviewPanel!) {
        panel.dataSource = nil
    }
    
    private func writeSelectionToQuickLookPasteboard() {
        quickLookHandler.pasteboard.clearContents()
        delegate?.collectionView?(self, writeItemsAtIndexPaths: selectionIndexPaths, toPasteboard: quickLookHandler.pasteboard)
    }
    
}

@objc private class QuickLookableCollectionViewPreviewHandler: NSObject, QLPreviewPanelDataSource {
    
    var pasteboard: NSPasteboard!
    
    @objc private func numberOfPreviewItemsInPreviewPanel(panel: QLPreviewPanel!) -> Int {
        guard let items = pasteboard.pasteboardItems else { return 0 }
        
        return items.count
    }
    
    @objc private func previewPanel(panel: QLPreviewPanel!, previewItemAtIndex index: Int) -> QLPreviewItem! {
        guard let items = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else { return nil }
        
        return NSURL(fileURLWithPath: items[index])
    }
    
}
