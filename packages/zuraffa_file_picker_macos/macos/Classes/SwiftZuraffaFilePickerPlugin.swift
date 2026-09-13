import FlutterMacOS
import AppKit
import UniformTypeIdentifiers

/// The macOS file picker: NSOpenPanel / NSSavePanel behind the shared
/// `zuraffa_file_picker` channel.
///
/// Panels run non-modally via `begin(completionHandler:)` so the engine
/// stays responsive. A dismissed panel resolves `nil` — cancellation is
/// a value, never an exception.
public class ZuraffaFilePickerPlugin: NSObject, FlutterPlugin {
    private static let channelName = "zuraffa_file_picker"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger
        )
        let instance = ZuraffaFilePickerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = (call.arguments as? [String: Any]) ?? [:]
        switch call.method {
        case "pickFiles":
            pickFiles(args, result)
        case "saveFile":
            saveFile(args, result)
        case "pickDirectory":
            pickDirectory(args, result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Pick files

    private func pickFiles(_ args: [String: Any], _ result: @escaping FlutterResult) {
        let type = args["type"] as? String ?? "any"
        let extensions = args["allowedExtensions"] as? [String] ?? []
        let multiple = args["multiple"] as? Bool ?? false

        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = multiple
            panel.allowedContentTypes = self.contentTypes(for: type, extensions: extensions)
            if let initial = args["initialDirectory"] as? String {
                panel.directoryURL = URL(fileURLWithPath: initial)
            }
            panel.begin { response in
                guard response == .OK else {
                    result(nil)
                    return
                }
                let payload: [[String: Any?]] = panel.urls.map { url in
                    [
                        "path": url.path,
                        "name": url.lastPathComponent,
                        "size": self.fileSize(at: url),
                        "mimeType": (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType)?.preferredMIMEType,
                    ]
                }
                result(payload)
            }
        }
    }

    // MARK: - Save file

    private func saveFile(_ args: [String: Any], _ result: @escaping FlutterResult) {
        let fileName = args["fileName"] as? String ?? "document"
        let bytes = args["bytes"] as? FlutterStandardTypedData

        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.nameFieldStringValue = fileName
            let extensionName = (fileName as NSString).pathExtension
            if !extensionName.isEmpty {
                panel.allowedContentTypes = self.contentTypes(for: "custom", extensions: [extensionName])
            }
            if let initial = args["initialDirectory"] as? String {
                panel.directoryURL = URL(fileURLWithPath: initial)
            }
            panel.begin { response in
                guard response == .OK, let url = panel.url else {
                    result(nil)
                    return
                }
                if let bytes = bytes {
                    do {
                        try bytes.data.write(to: url)
                    } catch {
                        result(FlutterError(
                            code: "write_failed",
                            message: error.localizedDescription,
                            details: nil
                        ))
                        return
                    }
                }
                result(url.path)
            }
        }
    }

    // MARK: - Pick directory

    private func pickDirectory(_ args: [String: Any], _ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            if let initial = args["initialDirectory"] as? String {
                panel.directoryURL = URL(fileURLWithPath: initial)
            }
            panel.begin { response in
                guard response == .OK, let url = panel.url else {
                    result(nil)
                    return
                }
                result(url.path)
            }
        }
    }

    // MARK: - Helpers

    private func contentTypes(for type: String, extensions: [String]) -> [UTType] {
        switch type {
        case "image":
            return [.image]
        case "video":
            return [.movie, .video]
        case "audio":
            return [.audio]
        case "media":
            return [.audiovisualContent, .image]
        case "custom":
            let mapped = extensions.compactMap { UTType(filenameExtension: $0.lowercased()) }
            return mapped.isEmpty ? [.data] : mapped
        default:
            return [.item]
        }
    }

    private func fileSize(at url: URL) -> Int {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? NSNumber)?.intValue ?? 0
    }
}
