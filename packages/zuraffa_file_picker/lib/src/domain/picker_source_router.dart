import 'entities/enums/file_type.dart';
import 'entities/enums/picker_host.dart';
import 'entities/enums/picker_source.dart';

/// Resolves which native picker source serves a pick request.
///
/// This is the single authority for the media-source routing (spec 002,
/// issue #2): the adapters call [resolve] and send the resolved source
/// over the wire, so the native side only switches on an explicit
/// `document` / `photoLibrary` value and never re-derives the rule.
///
/// The rule mirrors `file_picker`'s iOS behavior, which zik_zak's
/// price-check invoice flow depends on (`uploadInvoice`):
///
/// | request (ios host)         | resolved source |
/// | -------------------------- | --------------- |
/// | `media` / `image` / `video`| photo library   |
/// | `any` / `audio` / `custom` | document        |
/// | explicit `document`        | document        |
/// | explicit `photoLibrary` + `media`/`image`/`video` | photo library |
///
/// The photo library (PHPicker) carries images, videos and live photos —
/// **not** standalone audio or arbitrary documents — so an explicit
/// `photoLibrary` request for a type the photo library cannot serve
/// degrades to the document picker rather than opening an unfiltered
/// surface. Off iOS the photo source does not exist yet (Android reaches
/// photos through the document provider, macOS has no photo panel), so
/// every request resolves to the document picker.
abstract final class PickerSourceRouter {
  /// The extensions a photo-library pick can return.
  ///
  /// The invoice flow pins `heic` on this set: HEIC is what iOS cameras
  /// produce, and `media` + `['jpg', 'jpeg', 'png', 'heic']` must accept
  /// all four. Note the document picker honors `allowedExtensions`
  /// exactly, while the photo source filters by *kind* (images / videos)
  /// and ignores extensions — like `file_picker`'s `FileType.media`.
  static const photoLibraryExtensions = {
    'jpg',
    'jpeg',
    'png',
    'heic',
    'heif',
    'gif',
    'webp',
    'tiff',
    'bmp',
    'dng',
    'mov',
    'mp4',
    'm4v',
  };

  /// The file types the photo library can serve.
  static const photoLibraryTypes = {
    FileType.media,
    FileType.image,
    FileType.video,
  };

  /// Resolves the source that serves [options] of [type] on [host].
  ///
  /// An explicit [requested] source wins when the host has it and the
  /// type is photo-library servable; [PickerSource.auto] applies the
  /// per-host defaults above.
  static PickerSource resolve({
    required FileType type,
    PickerSource requested = PickerSource.auto,
    required PickerHost host,
  }) {
    final photoServable =
        photoLibraryTypes.contains(type) && host == PickerHost.ios;
    switch (requested) {
      case PickerSource.document:
        return PickerSource.document;
      case PickerSource.photoLibrary:
        return photoServable
            ? PickerSource.photoLibrary
            : PickerSource.document;
      case PickerSource.auto:
        return photoServable
            ? PickerSource.photoLibrary
            : PickerSource.document;
    }
  }

  /// Whether [extension] (case-insensitive, without the dot) is an
  /// extension a photo-library pick can produce.
  static bool isPhotoLibraryExtension(String extension) =>
      photoLibraryExtensions.contains(extension.toLowerCase());

  /// Whether every extension in [extensions] is photo-library producible.
  ///
  /// Used to pin that a caller's extension list is fully honored by the
  /// media (photo) shape — e.g. the invoice flow's
  /// `['jpg', 'jpeg', 'png', 'heic']`.
  static bool supportsPhotoLibraryExtensions(Iterable<String> extensions) =>
      extensions.every(isPhotoLibraryExtension);
}
