/// The picker filter applied to the file dialog (FR-004).
enum FileType {
  /// No filter — every file is selectable.
  any,

  /// Images, video and audio.
  media,

  /// Images only.
  image,

  /// Video only.
  video,

  /// Audio only.
  audio,

  /// Custom filter — requires [FilePickOptions.allowedExtensions] to be
  /// non-empty; the service rejects a custom type without one with a
  /// typed `missing_allowed_extensions` error.
  custom,
}
