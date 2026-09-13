// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'picked_file.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class PickedFile {
  PickedFile({
    required String this.path,
    required String this.name,
    required int this.size,
    String? this.mimeType,
  });

  factory PickedFile.fromJson(Map<String, dynamic> json) =>
      _$PickedFileFromJson(json);

  final String path;

  final String name;

  final int size;

  final String? mimeType;

  PickedFile copyWith({
    String? path,
    String? name,
    int? size,
    String? mimeType,
  }) {
    return PickedFile(
      path: path ?? this.path,
      name: name ?? this.name,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  PickedFile copyWithField<T>(Field<PickedFile, T> field, T value) {
    switch (field.name) {
      case 'path':
        return copyWith(path: value as String);
      case 'name':
        return copyWith(name: value as String);
      case 'size':
        return copyWith(size: value as int);
      case 'mimeType':
        return copyWith(mimeType: value as String?);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'PickedFile has no settable field with this name',
        );
    }
  }

  PickedFile copyWithPickedFile({
    String? path,
    String? name,
    int? size,
    String? mimeType,
  }) {
    return copyWith(path: path, name: name, size: size, mimeType: mimeType);
  }

  PickedFile patchWithPickedFile([PickedFilePatch? patchInput]) {
    final _patcher = patchInput ?? PickedFilePatch();
    final _patchMap = _patcher.patchMap;
    return PickedFile(
      path: _patchMap.containsKey(PickedFile$.path)
          ? ((_patchMap[PickedFile$.path] is Function)
                    ? _patchMap[PickedFile$.path](this.path)
                    : (_patchMap[PickedFile$.path] is Patch)
                    ? _patchMap[PickedFile$.path].applyTo(this.path)
                    : _patchMap[PickedFile$.path])
                as String
          : this.path,
      name: _patchMap.containsKey(PickedFile$.name_)
          ? ((_patchMap[PickedFile$.name_] is Function)
                    ? _patchMap[PickedFile$.name_](this.name)
                    : (_patchMap[PickedFile$.name_] is Patch)
                    ? _patchMap[PickedFile$.name_].applyTo(this.name)
                    : _patchMap[PickedFile$.name_])
                as String
          : this.name,
      size: _patchMap.containsKey(PickedFile$.size)
          ? ((_patchMap[PickedFile$.size] is Function)
                    ? _patchMap[PickedFile$.size](this.size)
                    : (_patchMap[PickedFile$.size] is Patch)
                    ? _patchMap[PickedFile$.size].applyTo(this.size)
                    : _patchMap[PickedFile$.size])
                as int
          : this.size,
      mimeType: _patchMap.containsKey(PickedFile$.mimeType)
          ? ((_patchMap[PickedFile$.mimeType] is Function)
                    ? _patchMap[PickedFile$.mimeType](this.mimeType)
                    : (_patchMap[PickedFile$.mimeType] is Patch)
                    ? _patchMap[PickedFile$.mimeType].applyTo(this.mimeType)
                    : _patchMap[PickedFile$.mimeType])
                as String?
          : this.mimeType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PickedFile &&
        path == other.path &&
        name == other.name &&
        size == other.size &&
        mimeType == other.mimeType;
  }

  @override
  int get hashCode {
    return Object.hash(this.path, this.name, this.size, this.mimeType);
  }

  @override
  String toString() {
    return 'PickedFile(' +
        'path: ${path}' +
        ', ' +
        'name: ${name}' +
        ', ' +
        'size: ${size}' +
        ', ' +
        'mimeType: ${mimeType})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$PickedFileToJson(this);
    _sanitizeJson(data);
    return data;
  }

  dynamic _sanitizeJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      json.remove('__typename');
      return json..forEach((key, value) {
        json[key] = _sanitizeJson(value);
      });
    } else if (json is List) {
      return json.map((e) => _sanitizeJson(e)).toList();
    }
    return json;
  }
}

extension PickedFilePropertyHelpers on PickedFile {
  bool get hasPath {
    return this.path.isNotEmpty;
  }

  bool get noPath {
    return this.path.isEmpty;
  }

  bool get hasName {
    return this.name.isNotEmpty;
  }

  bool get noName {
    return this.name.isEmpty;
  }

  bool get hasMimeType {
    return this.mimeType?.isNotEmpty == true;
  }

  bool get noMimeType {
    return this.mimeType?.isEmpty ?? true;
  }

  String get mimeTypeRequired {
    return this.mimeType ??
        (throw StateError('mimeType is required but was null'));
  }
}

extension PickedFileSerialization on PickedFile {
  Map<String, dynamic> toJson() {
    return _$PickedFileToJson(this);
  }
}

enum PickedFile$ { path, name_, size, mimeType }

class PickedFilePatch extends PatchBase<PickedFile, PickedFile$> {
  PickedFile applyTo(PickedFile entity) {
    return entity.patchWithPickedFile(this);
  }

  PickedFilePatch withPath(String? value) {
    patchMap[PickedFile$.path] = value;
    return this;
  }

  PickedFilePatch withName(String? value) {
    patchMap[PickedFile$.name_] = value;
    return this;
  }

  PickedFilePatch withSize(int? value) {
    patchMap[PickedFile$.size] = value;
    return this;
  }

  PickedFilePatch withMimeType(String? value) {
    patchMap[PickedFile$.mimeType] = value;
    return this;
  }
}

/// Field descriptors for [PickedFile] query construction
abstract final class PickedFileFields {
  static const path = Field<PickedFile, String>('path', _$path);

  static const name = Field<PickedFile, String>('name', _$name);

  static const size = Field<PickedFile, int>('size', _$size);

  static const mimeType = Field<PickedFile, String?>('mimeType', _$mimeType);

  static String _$path(PickedFile e) {
    return e.path;
  }

  static String _$name(PickedFile e) {
    return e.name;
  }

  static int _$size(PickedFile e) {
    return e.size;
  }

  static String? _$mimeType(PickedFile e) {
    return e.mimeType;
  }
}

extension PickedFileCompareE on PickedFile {
  Map<String, dynamic> compareToPickedFile(PickedFile other) {
    final Map<String, dynamic> diff = {};

    if (path != other.path) {
      diff['path'] = () => other.path;
    }

    if (name != other.name) {
      diff['name'] = () => other.name;
    }

    if (size != other.size) {
      diff['size'] = () => other.size;
    }

    if (mimeType != other.mimeType) {
      diff['mimeType'] = () => other.mimeType;
    }
    return diff;
  }
}
