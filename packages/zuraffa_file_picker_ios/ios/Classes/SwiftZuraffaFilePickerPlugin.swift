import Flutter
import UniformTypeIdentifiers

/// The iOS file picker: UIDocumentPickerViewController behind the shared
/// `zuraffa_file_picker` channel.
///
/// File picks use `asCopy: true` so every descriptor carries a real,
/// readable filesystem path (the system copies the documents into our
/// tmp). Save exports a staged temp file into the user-chosen location
/// and returns its path. A dismissed picker resolves `nil` —
/// cancellation is a value, never an exception.
public class ZuraffaFilePickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
    private static let channelName = "zuraffa_file_picker"

    private enum PickerMode {
        case pickFiles
        case saveFile
        case pickDirectory
    }

    private let channel: FlutterMethodChannel
    private var pendingResult: FlutterResult?
    private var pendingMode: PickerMode = .pickFiles

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = ZuraffaFilePickerPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if pendingResult != nil {
            result(FlutterError(
                code: "already_active",
                message: "Another picker operation is in progress.",
                details: nil
            ))
            return
        }
        switch call.method {
        case "pickFiles":
            pendingMode = .pickFiles
            presentFiles(arguments(call), result)
        case "saveFile":
            pendingMode = .saveFile
            presentSave(arguments(call), result)
        case "pickDirectory":
            pendingMode = .pickDirectory
            presentDirectory(arguments(call), result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func arguments(_ call: FlutterMethodCall) -> [String: Any] {
        (call.arguments as? [String: Any]) ?? [:]
    }

    // MARK: - Pick files

    private func presentFiles(_ args: [String: Any], _ result: @escaping FlutterResult) {
        let type = args["type"] as? String ?? "any"
        let extensions = args["allowedExtensions"] as? [String] ?? []
        let multiple = args["multiple"] as? Bool ?? false

        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: contentTypes(for: type, extensions: extensions),
            asCopy: true
        )
        picker.allowsMultipleSelection = multiple
        if let initial = args["initialDirectory"] as? String {
            picker.directoryURL = URL(fileURLWithPath: initial)
        }
        present(picker, result)
    }

    // MARK: - Save file

    private func presentSave(_ args: [String: Any], _ result: @escaping FlutterResult) {
        let fileName = args["fileName"] as? String ?? "document"
        let bytes = args["bytes"] as? FlutterStandardTypedData

        // The export picker needs an existing file: stage the content in
        // tmp, the delegate receives the chosen destination.
        let staged = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        do {
            if let bytes = bytes {
                try bytes.data.write(to: staged)
            } else if !FileManager.default.fileExists(atPath: staged.path) {
                try Data().write(to: staged)
            }
        } catch {
            result(FlutterError(code: "staging_failed", message: error.localizedDescription, details: nil))
            return
        }

        let type = contentTypes(for: "custom", extensions: [staged.pathExtension])
        let picker = UIDocumentPickerViewController(forExporting: [staged], asCopy: false)
        if !type.isEmpty {
            picker.allowedContentTypes = type
        }
        if let initial = args["initialDirectory"] as? String {
            picker.directoryURL = URL(fileURLWithPath: initial)
        }
        present(picker, result)
    }

    // MARK: - Pick directory

    private func presentDirectory(_ args: [String: Any], _ result: @escaping FlutterResult) {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.folder],
            asCopy: false
        )
        if let initial = args["initialDirectory"] as? String {
            picker.directoryURL = URL(fileURLWithPath: initial)
        }
        present(picker, result)
    }

    // MARK: - Presentation + delegate

    private func present(_ picker: UIDocumentPickerViewController, _ result: @escaping FlutterResult) {
        picker.delegate = self
        DispatchQueue.main.async {
            guard let root = Self.topmostViewController() else {
                result(FlutterError(
                    code: "no_view_controller",
                    message: "File picker requires a presented view hierarchy.",
                    details: nil
                ))
                return
            }
            // iPad pickers require an anchor.
            picker.popoverPresentationController?.sourceView = root.view
            self.pendingResult = result
            root.present(picker, animated: true)
        }
    }

    private static func topmostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        let root = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController
            ?? scenes.first?.keyWindow?.rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    public func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        let result = pendingResult
        pendingResult = nil
        guard let result = result else { return }
        switch pendingMode {
        case .pickFiles:
            let payload: [[String: Any?]] = urls.map { url in
                [
                    "path": url.path,
                    "name": url.lastPathComponent,
                    "size": fileSize(at: url),
                    "mimeType": UTType(url: url)?.preferredMIMEType,
                ]
            }
            result(payload)
        case .saveFile:
            result(urls.first?.path)
        case .pickDirectory:
            result(urls.first?.path)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        let result = pendingResult
        pendingResult = nil
        result?(nil)
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
            let mapped = extensions.compactMap { UTType(filenameExtension: $0.lowercase()) }
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
