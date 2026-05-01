//
//  ImagesCollectionViewDataProvider.swift
//  Asset Catalog Tinkerer
//
//  Created by Guilherme Rambo on 27/03/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers
import ACS

extension NSUserInterfaceItemIdentifier {
    static let imageItemIdentifier = NSUserInterfaceItemIdentifier("ImageItemIdentifier")
}

// Custom pasteboard writer for colors that provides multiple representations
class ColorPasteboardWriter: NSObject, NSPasteboardWriting {
    let color: NSColor
    let image: NSImage
    let colorName: String
    
    init(color: NSColor, image: NSImage, name: String) {
        self.color = color
        self.image = image
        self.colorName = name
        super.init()
    }
    
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.fileURL, .color, .string, .tiff]
    }
    
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .fileURL:
            // Write image to temp file for QuickLook
            return temporaryFileURL()?.absoluteString
            
        case .color:
            // Write the actual NSColor object
            return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            
        case .string:
            // Write text representation (hex for sRGB, CSS color() for P3)
            return textRepresentation(for: color)
            
        case .tiff:
            // Write image representation for inline paste
            return image.tiffRepresentation
            
        default:
            return nil
        }
    }
    
    private func temporaryFileURL() -> URL? {
        // Create a safe filename
        let safeFilename = colorName
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("\(safeFilename).png")
        
        // Write PNG to temp file
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        try? pngData.write(to: tempURL, options: .atomic)
        return tempURL
    }
    
    private func textRepresentation(for color: NSColor) -> String {
        // Try to convert to sRGB first
        if let srgbColor = color.usingColorSpace(.sRGB) {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            // If it's in sRGB and not transparent, use hex
            if alpha >= 0.999 {
                return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
            } else {
                return String(format: "#%02X%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
            }
        }
        
        // Try Display P3
        if let p3Color = color.usingColorSpace(NSColorSpace.displayP3) {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            p3Color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            if alpha >= 0.999 {
                return String(format: "color(display-p3 %.3f %.3f %.3f)", red, green, blue)
            } else {
                return String(format: "color(display-p3 %.3f %.3f %.3f / %.3f)", red, green, blue, alpha)
            }
        }
        
        // Fallback to generic RGB
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "rgb(%.0f, %.0f, %.0f, %.2f)", red * 255, green * 255, blue * 255, alpha)
    }
}

class ImagesCollectionViewDataProvider: NSObject, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate struct Constants {
        static let nibName = "ImageCollectionViewItem"

    }
    
    var collectionView: NSCollectionView! {
        didSet {
            collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.collectionViewLayout = GridLayout()
            
            let nib = NSNib(nibNamed: Constants.nibName, bundle: nil)
            collectionView.register(nib, forItemWithIdentifier: .imageItemIdentifier)
        }
    }
    
    var images = [[String: NSObject]]() {
        didSet {
            filteredImages = filterImagesWithCurrentSearchTerm()
            collectionView.reloadData()
        }
    }
    
    var searchTerm = "" {
        didSet {
            filteredImages = filterImagesWithCurrentSearchTerm()
            collectionView.reloadData()
        }
    }
    
    var filteredImages = [[String: NSObject]]()
    
    fileprivate func filterImagesWithCurrentSearchTerm() -> [[String: NSObject]] {
        guard !searchTerm.isEmpty else { return images }
        
        let predicate = NSPredicate(format: "name contains[cd] %@", searchTerm)
        return (images as NSArray).filtered(using: predicate) as! [[String: NSObject]]
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .imageItemIdentifier, for: indexPath) as! ImageCollectionViewItem
        
        item.image = filteredImages[(indexPath as NSIndexPath).item]
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    private func canPerformPasteboardOperation(at indexPath: IndexPath) -> Bool {
        assert(indexPath.section == 0, "Only a single section is supported for now")
        assert(indexPath.item < filteredImages.count, "Invalid item index")
        
        return indexPath.item < filteredImages.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        guard canPerformPasteboardOperation(at: indexPath) else { return nil }
        
        // TODO: Use correct file type/extension instead of hardcoding png.
        let fileExtension = "png"
        
        let provider: NSFilePromiseProvider
        
        if #available(macOS 11.0, *) {
            let typeIdentifier = UTType(filenameExtension: fileExtension)
            provider = NSFilePromiseProvider(fileType: typeIdentifier!.identifier, delegate: self)
        } else {
            let typeIdentifier =
            UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)
            provider = NSFilePromiseProvider(fileType: typeIdentifier!.takeRetainedValue() as String, delegate: self)
        }
        
        provider.userInfo = self.filteredImages[indexPath.item]
        
        return provider
    }
    
    private lazy var filePromiseQueue = OperationQueue()
    
    private let copyQueue = DispatchQueue(label: "Copy", qos: .userInteractive)
    
    func generalPasteboardWriter(at indexPath: IndexPath) -> NSPasteboardWriting? {
        guard canPerformPasteboardOperation(at: indexPath) else { return nil }
        
        let image = filteredImages[indexPath.item]
        
        // Check if this is a color asset
        if let assetType = image[kACSTypeKey] as? String, assetType == "color",
           let color = image[kACSColorKey] as? NSColor,
           let thumbnail = image[kACSThumbnailKey] as? NSImage,
           let name = image[kACSNameKey] as? String {
            // For colors, use custom pasteboard writer with multiple representations
            return ColorPasteboardWriter(color: color, image: thumbnail, name: name)
        }

        // For images, write as file
        guard let filename = image[kACSFilenameKey] as? String else { return nil }
        guard let data = image[kACSContentsDataKey] as? Data else { return nil }

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(filename)

        do {
            try data.write(to: tempURL, options: .atomic)
            
            return tempURL as NSURL
        } catch {
            assertionFailure("Failed to write temporary URL for pasteboard: \(String(describing: error))")
            return nil
        }
    }
    
}

extension ImagesCollectionViewDataProvider: NSFilePromiseProviderDelegate {
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        guard let image = filePromiseProvider.userInfo as? [String: NSObject] else {
            return ""
        }
        
        guard let filename = image[kACSFilenameKey] as? String else { return "" }
        
        return filename
    }
    
    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue { filePromiseQueue }
    
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let image = filePromiseProvider.userInfo as? [String: NSObject] else {
            completionHandler(nil)
            return
        }
        
        guard let data = image[kACSContentsDataKey] as? Data else {
            completionHandler(nil)
            return
        }
        
        do {
            try data.write(to: url)
            
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
}
