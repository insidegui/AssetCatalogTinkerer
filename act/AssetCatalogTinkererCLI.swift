import Cocoa
import ACS
import ArgumentParser

struct ACTOptions: ParsableArguments {
    @Option(name: [.short, .long], help: "Path to input asset catalog.")
    var input: String
}

@main
struct AssetCatalogTinkererCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "act",
        abstract: "Command-line interface for interacting with asset catalog (.car) files.",
        subcommands: [
            InfoCommand.self,
            ExtractCommand.self
        ]
    )

    @OptionGroup
    var options: ACTOptions
}

private extension AssetCatalogReader {
    static func images(from url: URL) async throws -> [[String: NSObject]] {
        let reader = AssetCatalogReader(fileURL: url)

        await withCheckedContinuation { continuation in
            reader.read {
                continuation.resume()
            } progressHandler: { progress in
                fputs("Reading... \(String(format: "%02.0f%%", progress * 100))\n", stderr)
            }
        }

        return reader.images
    }
}

struct InfoCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "info",
        abstract: "Retrieves information about assets in an asset catalog file,"
    )

    @OptionGroup
    var options: ACTOptions

    func run() async throws {
        let inputURL = try options.input.resolvedExistingFileURL()
        
        let images = try await AssetCatalogReader.images(from: inputURL)

        for image in images {
            guard let filename = image[kACSFilenameKey] as? String else { continue }
            print(filename)
        }
    }
}

struct ExtractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract",
        abstract: "Extracts assets from an asset catalog file."
    )

    @OptionGroup
    var options: ACTOptions

    @Option(name: [.short, .long], help: "Path to directory where to save the extracted assets. Will be created if it doesn't exist yet.")
    var output: String

    func run() async throws {
        let inputURL = try options.input.resolvedExistingFileURL()
        let outputURL = output.resolvedURL

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: false)
        }

        guard outputURL.isExistingDirectory else {
            throw "Output must be a directory: \(outputURL.path)"
        }

        let images = try await AssetCatalogReader.images(from: inputURL)

        guard !images.isEmpty else {
            throw "Asset catalog had no images at \(inputURL.path)"
        }

        let exporter = ImageExporter(images: images)

        await exporter.export(toDirectoryAt: outputURL)

        print("Exported \(images.count) images to \(outputURL.path)\n")
    }
}
