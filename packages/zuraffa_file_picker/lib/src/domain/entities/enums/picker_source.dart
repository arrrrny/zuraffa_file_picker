/// The native picker source that serves a [FilePickOptions] request.
///
/// Consumers usually leave this at [auto] and let the federated adapter
/// resolve the right source for the platform — `media`/`image`/`video`
/// resolve to the photo library on iOS (PHPicker) and to the document
/// picker elsewhere, matching `file_picker`'s `FileType.media` behavior.
/// The explicit values are an escape hatch for callers that want to force
/// a particular source.
enum PickerSource {
  /// Let the adapter choose based on the file type and platform.
  auto,

  /// The system document picker (UIDocumentPickerViewController on
  /// iOS / ACTION_OPEN_DOCUMENT on Android / NSOpenPanel on macOS).
  /// Honors [FilePickOptions.allowedExtensions] for [FileType.custom].
  document,

  /// The photo library (iOS PHPickerViewController). Available on iOS
  /// only; degrades to [document] on the other platforms.
  photoLibrary,
}
