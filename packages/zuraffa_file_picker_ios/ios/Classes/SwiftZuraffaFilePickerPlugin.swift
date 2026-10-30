import Flutter
import PhotosUI
import UniformTypeIdentifiers

/// The iOS file picker behind the shared `zuraffa_file_picker` channel.
///
/// Two picker sources serve `pickFiles` (spec 002, spec 1206 FR-4/FR-5):
///
/// - **document** — `UIDocumentPickerViewController` ("Browse/upload from
///   device" on iOS 16+). Honors `allowedExtensions` for `custom`.
/// - **photoLibrary** — `PHPickerViewController`, the photo-library source
///   `file_picker`'s `FileType.media` provides: it browses the *whole*
///   photo library (no "Recents only" trap), needs no permission string
///   and serves images, videos and live photos. HEIC reaches the app as
///   the original file, so `size` is the real byte size.
///
/// The Dart side resolves which source runs (`PickerSourceRouter`) and
/// sends it as the explicit `source` key; this side only switches on the
/// value and defaults to `document` when it is absent.
///
/// File picks use `asCopy: true` / an explicit temp copy of every file
/// representation so every descriptor carries a real, readable
/// filesystem path (the system copies the documents into our tmp).
/// Save exports a staged temp file into the user-chosen location and
/// returns its path. A dismissed picker resolves `nil` — cancellation is
/// a value, never an exception.
public class ZuraffaFilePickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate, PHPickerViewControllerDelegate {
    private static let channelName = "zuraffa_file_picker"
    private static let pickerTempDirName = "zuraffa_file_picker"

    private enum PickerMode {
        case pickFiles
        case saveFile
        case pickDirectory
    }

    private enum PickerSource {
        case document
        case photoLibrary

        init?(raw: String?) {
            switch raw {
            case "photoLibrary": self = .photoLibrary
            default: self = .document
            }
        }
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
        let source = PickerSource(raw: args["source"] as? String)

        switch source {
        case .photoLibrary:
            presentPhotoLibrary(type: type, multiple: multiple, result)
        case .document:
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
    }

    /// Presents the photo-library picker (spec 002 FR-1). The caller's
    /// `allowedExtensions` are advisory here: PHPicker filters by *kind*
    /// and serves every image/video the library holds — HEIC included —
    /// matching `file_picker`'s `FileType.media` semantics.
    private func presentPhotoLibrary(type: String, multiple: Bool, _ result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            guard let root = Self.topmostViewController() else {
                result(FlutterError(
                    code: "no_view_controller",
                    message: "File picker requires a presented view hierarchy.",
                    details: nil
                ))
                return
            }
            var configuration = PHPickerConfiguration()
            configuration.filter = Self.photoLibraryFilter(for: type)
            configuration.selectionLimit = multiple ? 0 : 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            // iPad pickers require an anchor.
            picker.popoverPresentationController?.sourceView = root.view
            self.pendingResult = result
            root.present(picker, animated: true)
        }
    }

    private static func photoLibraryFilter(for type: String) -> PHPickerFilter {
        switch type {
        case "video": return .videos
        case "media": return .any(of: [.images, .videos, .livePhotos])
        default: return .images
        }
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

        let picker = UIDocumentPickerViewController(forExporting: [staged], asCopy: false)
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

    // MARK: - Presentation + document delegate

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
                    "mimeType": UTType(filenameExtension: url.pathExtension)?.preferredMIMEType
                        ?? (try? url.resourceValues(forKeys: [.contentTypeKey]).contentType)?.preferredMIMEType,
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

    // MARK: - Photo-library delegate (spec 002 FR-1/FR-3)

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let result = pendingResult
        pendingResult = nil
        guard let result = result else { return }

        // An empty result set is the user dismissing the picker.
        guard !results.isEmpty else {
            result(nil)
            return
        }

        // Copy every picked item's file representation into our tmp — the
        // representation URL is only valid inside this completion block —
        // so each descriptor carries a readable path + real byte size.
        var descriptors = [[String: Any?]](repeating: [:], count: results.count)
        let lock = NSLock()
        let group = DispatchGroup()
        for (index, item) in results.enumerated() {
            let provider = item.itemProvider
            guard let typeIdentifier = pickableTypeIdentifier(from: provider) else { continue }
            group.enter()
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                defer { group.leave() }
                guard let url = url, error == nil,
                      let copied = Self.copyIntoPickerTemp(url, provider: provider) else {
                    return
                }
                let descriptor: [String: Any?] = [
                    "path": copied.path,
                    "name": copied.lastPathComponent,
                    "size": Self.fileSize(at: copied),
                    "mimeType": UTType(filenameExtension: copied.pathExtension)?.preferredMIMEType,
                ]
                lock.lock()
                descriptors[index] = descriptor
                lock.unlock()
            }
        }
        group.notify(queue: .main) {
            result(descriptors.filter { !$0.isEmpty })
        }
    }

    /// The type identifier to load for a picked item: prefer the item's
    /// native image/movie representation (the original HEIC for iPhone
    /// photos, not a transcoded copy) over a fallback like `public.jpeg`.
    private func pickableTypeIdentifier(from provider: NSItemProvider) -> String? {
        let identifiers = provider.registeredTypeIdentifiers
        for identifier in identifiers {
            guard let type = UTType(identifier) else { continue }
            if type.conforms(to: .image) || type.conforms(to: .movie) {
                return identifier
            }
        }
        return identifiers.first
    }

    /// Copies a picked item's representation into `tmp/zuraffa_file_picker/`
    /// under a stable, unique, app-chosen name so the descriptor is valid
    /// long after the completion block ends.
    private static func copyIntoPickerTemp(_ url: URL, provider: NSItemProvider) -> URL? {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(pickerTempDirName, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        } catch {
            return nil
        }
        // Prefer the item's suggested name (e.g. `IMG_0001`) with the
        // representation's real extension, so `name` reads like the
        // picker's and the extension keeps the MIME type derivable.
        let extensionName = url.pathExtension.isEmpty ? "dat" : url.pathExtension
        let baseName = (provider.suggestedName ?? url.deletingPathExtension().lastPathComponent)
            .replacingOccurrences(of: "/", with: "_")
        let fileName = "\(UUID().uuidString)_\(baseName).\(extensionName)"
        let target = dir.appendingPathComponent(fileName)
        do {
            try FileManager.default.copyItem(at: url, to: target)
        } catch {
            return nil
        }
        return target
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
            // Only reached with an explicit `document` source; the photo
            // library does not serve standalone audio, so the document
            // picker's audiovisual surface remains the default.
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
