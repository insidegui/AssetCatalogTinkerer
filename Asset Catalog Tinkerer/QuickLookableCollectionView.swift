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
    
    typealias PasteboardWriterProvidingBlock = (Set<IndexPath>) -> [NSPasteboardWriting]
    
    var provideQuickLookPasteboardWriters: PasteboardWriterProvidingBlock?

    override func keyDown(with theEvent: NSEvent) {
        // spacebar
        if theEvent.keyCode == 49 {
            showQuickLookPreview(self);
            return;
        }
        
        super.keyDown(with: theEvent)
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
        guard let items = provideQuickLookPasteboardWriters?(selectionIndexPaths) else { return }
        
        quickLookHandler.pasteboard.clearContents()
        quickLookHandler.pasteboard.writeObjects(items)
    }
    
    private var selectionObservation: NSKeyValueObservation?
    
    fileprivate var isWindowClosing = false
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        
        guard newWindow != nil else { return }
        
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: newWindow, queue: .main) { [weak self] _ in
            self?.isWindowClosing = true
            
            QLPreviewPanel.shared().close()
        }
        
        // Handles updating the QuickLook panel when selection changes.
        selectionObservation = observe(\.selectionIndexPaths) { [weak self] _, _ in
            guard let self = self else { return }
            
            self.updateQuickLookWithNewSelectionIfNeeded()
        }
    }
    
    private func updateQuickLookWithNewSelectionIfNeeded() {
        guard QLPreviewPanel.sharedPreviewPanelExists() && QLPreviewPanel.shared().isVisible else { return }
        
        writeSelectionToQuickLookPasteboard()
        QLPreviewPanel.shared().reloadData()
    }
    
}

@objc private class QuickLookableCollectionViewPreviewHandler: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    
    var pasteboard: NSPasteboard!
    var collectionView: QuickLookableCollectionView!
    
    var previewItems: [URL] {
        pasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.compactMap { $0 as? URL } ?? []
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
        guard let window = collectionView.window else { return .zero }
        guard !collectionView.isWindowClosing else { return .zero }
        
        let combinedRect = collectionView.selectionIndexes.map { return collectionView.frameForItem(at: $0) }.reduce(NSZeroRect) { NSUnionRect($0, $1) }
        
        var preliminaryRect = collectionView.enclosingScrollView!.convert(combinedRect, to: nil)
        preliminaryRect.origin.y += collectionView.enclosingScrollView!.contentView.bounds.origin.y
        let rect = window.convertToScreen(preliminaryRect)
        
        // Prevent ludicrously tall rect from causing glitchy panel open,
        // should probably fix the rect calculation instead but I'm lazy.
        guard rect.height < window.frame.height else { return .zero }
        
        return rect
    }
    
}
