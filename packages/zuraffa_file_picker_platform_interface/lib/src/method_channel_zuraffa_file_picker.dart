import 'package:flutter/services.dart';

import 'file_picker_platform_interface.dart';

/// The MethodChannel client half: what the native Kotlin/Swift plugins
/// implement. Platform packages re-export this as their registration
/// target so the channel name and protocol stay identical across
/// platforms.
class MethodChannelZuraffaFilePicker extends ZuraffaFilePickerPlatform {
  /// The shared channel — every platform package registers the same
  /// name (`zuraffa_file_picker`).
  static const MethodChannel channel = MethodChannel('zuraffa_file_picker');

  @override
  Future<List<Map<Object?, Object?>>?> pickFiles(
    Map<Object?, Object?> options,
  ) async {
    final raw = await channel.invokeMethod<List<Object?>?>(
      FilePickerWire.pickFiles,
      options,
    );
    return raw
        ?.map((entry) => Map<Object?, Object?>.from(entry as Map))
        .toList();
  }

  @override
  Future<String?> saveFile(Map<Object?, Object?> options) =>
      channel.invokeMethod<String?>(FilePickerWire.saveFile, options);

  @override
  Future<String?> pickDirectory(String? initialDirectory) =>
      channel.invokeMethod<String?>(
        FilePickerWire.pickDirectory,
        initialDirectory,
      );
}
