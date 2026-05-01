import Cocoa

public struct ImageExporter {
    public let images: [[String: NSObject]]

    public init(images: [[String : NSObject]]) {
        self.images = images
    }

    @available(macOS 10.15, *)
    public func export(toDirectoryAt url: URL) async {
        await withCheckedContinuation { continuation in
            export(toDirectoryAt: url) {
                continuation.resume()
            }
        }
    }

    public func export(toDirectoryAt url: URL, completionHandler: (() -> Void)? = nil) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            images.forEach { image in
                guard let filename = image[kACSFilenameKey] as? String else { return }

                var pathComponents = url.pathComponents

                pathComponents.append(filename)

                guard let contentsData = image[kACSContentsDataKey] as? Data else { return }

                let path = self.nextAvailablePath(filePath: NSString.path(withComponents: pathComponents) as String)
                do {
                    try contentsData.write(to: URL(fileURLWithPath: path), options: .atomic)
                } catch {
                    NSLog("ERROR: Unable to write \(filename) to \(path); \(error)")
                }
            }

            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }

    private func nextAvailablePath(filePath: String) -> String {
        let fileManager = FileManager.default
        let originalURL = URL(fileURLWithPath: filePath)
        let directory = originalURL.deletingLastPathComponent()
        let baseFilename = originalURL.deletingPathExtension().lastPathComponent
        let fileExtension = originalURL.pathExtension

        var counter = 1
        var newFilename = baseFilename

        while fileManager.fileExists(atPath: directory.appendingPathComponent(newFilename).appendingPathExtension(fileExtension).path) && counter < 100 {
            newFilename = "\(baseFilename)_\(counter)"
            counter += 1
        }

        return directory.appendingPathComponent(newFilename).appendingPathExtension(fileExtension).path
    }
}
