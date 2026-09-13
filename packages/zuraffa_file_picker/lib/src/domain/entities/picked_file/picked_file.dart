import 'package:zorphy_annotation/zorphy_annotation.dart';

part 'picked_file.zorphy.dart';
part 'picked_file.g.dart';

/// A file the user picked (FR-002): a real filesystem path plus the
/// metadata apps reach for most. The bytes are always readable from
/// [path] — the platform adapters copy picked documents into app-accessible
/// storage, so no content-URI or security-scoped bookkeeping leaks here.
@Zorphy(generateJson: true)
abstract class $PickedFile {
  /// A readable filesystem path (a copy of the picked document).
  String get path;

  /// The file name as shown by the picker.
  String get name;

  /// Size in bytes.
  int get size;

  /// Best-effort MIME type (`image/png`), `null` when the platform
  /// could not determine one.
  String? get mimeType;
}
