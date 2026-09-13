// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picked_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedFile _$PickedFileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PickedFile', json, ($checkedConvert) {
      final val = PickedFile(
        path: $checkedConvert('path', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        size: $checkedConvert('size', (v) => (v as num).toInt()),
        mimeType: $checkedConvert('mimeType', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PickedFileToJson(PickedFile instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'size': instance.size,
      'mimeType': ?instance.mimeType,
    };
