// Behavioral suite for spec 002-media-source-pick (issue #2) — pure Dart.
//
// Media-source routing (PickerSourceRouter) · invoice-flow parity:
// the two shapes zik_zak's `uploadInvoice` sends (custom+['pdf'] and
// media+['jpg','jpeg','png','heic']) · PickedFile field population ·
// the cancellation contract, all through the in-memory scripted adapter.
import 'package:test/test.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';

/// The PDF invoice shape of zik_zak's `uploadInvoice`.
const _pdfInvoiceOptions = FilePickOptions(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
);

/// The photo invoice shape of zik_zak's `uploadInvoice`.
const _photoInvoiceOptions = FilePickOptions(
  type: FileType.media,
  allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
);

void main() {
  group('PickerSourceRouter (spec 002 FR-1)', () {
    test('ios routes media, image and video to the photo library', () {
      for (final type in [FileType.media, FileType.image, FileType.video]) {
        expect(
          PickerSourceRouter.resolve(type: type, host: PickerHost.ios),
          PickerSource.photoLibrary,
          reason:
              '$type on iOS opens the photo library (PHPicker), '
              'matching file_picker FileType.media semantics',
        );
      }
    });

    test('ios routes any, audio and custom to the document picker', () {
      for (final type in [FileType.any, FileType.audio, FileType.custom]) {
        expect(
          PickerSourceRouter.resolve(type: type, host: PickerHost.ios),
          PickerSource.document,
          reason:
              '$type on iOS opens the document picker — '
              'custom extensions are honored there',
        );
      }
    });

    test('an explicit document request always wins', () {
      for (final type in FileType.values) {
        expect(
          PickerSourceRouter.resolve(
            type: type,
            requested: PickerSource.document,
            host: PickerHost.ios,
          ),
          PickerSource.document,
        );
      }
    });

    test('an explicit photoLibrary request is honored only where servable', () {
      for (final type in [FileType.media, FileType.image, FileType.video]) {
        expect(
          PickerSourceRouter.resolve(
            type: type,
            requested: PickerSource.photoLibrary,
            host: PickerHost.ios,
          ),
          PickerSource.photoLibrary,
        );
      }
      // The photo library cannot serve documents or standalone audio.
      for (final type in [FileType.custom, FileType.audio, FileType.any]) {
        expect(
          PickerSourceRouter.resolve(
            type: type,
            requested: PickerSource.photoLibrary,
            host: PickerHost.ios,
          ),
          PickerSource.document,
          reason:
              '$type is not photo-library servable; degrade, never open '
              'an unfiltered surface',
        );
      }
    });

    test('hosts without a photo source resolve to the document picker', () {
      for (final host in [
        PickerHost.android,
        PickerHost.macos,
        PickerHost.other,
      ]) {
        for (final type in FileType.values) {
          expect(
            PickerSourceRouter.resolve(type: type, host: host),
            PickerSource.document,
            reason: '$type on $host has no photo-library source yet',
          );
        }
      }
    });
  });

  group('photo-library extension coverage (spec 002 FR-2)', () {
    test('the invoice photo shape is fully photo-library producible', () {
      expect(
        PickerSourceRouter.supportsPhotoLibraryExtensions([
          'jpg',
          'jpeg',
          'png',
          'heic',
        ]),
        isTrue,
        reason: 'the invoice flow depends on heic reaching the picker',
      );
      for (final extension in ['jpg', 'jpeg', 'png', 'heic']) {
        expect(PickerSourceRouter.isPhotoLibraryExtension(extension), isTrue);
      }
    });

    test('case-insensitive and dot-form aware', () {
      expect(PickerSourceRouter.isPhotoLibraryExtension('HEIC'), isTrue);
      expect(PickerSourceRouter.isPhotoLibraryExtension('JPG'), isTrue);
    });

    test('documents are not photo-library producible', () {
      expect(PickerSourceRouter.isPhotoLibraryExtension('pdf'), isFalse);
      expect(
        PickerSourceRouter.supportsPhotoLibraryExtensions(['pdf']),
        isFalse,
        reason: 'custom+pdf is a document-picker shape by contract',
      );
    });
  });

  group('FilePickOptions.source (spec 002 FR-1)', () {
    test('defaults to auto', () {
      expect(_pdfInvoiceOptions.source, PickerSource.auto);
      expect(_photoInvoiceOptions.source, PickerSource.auto);
      expect(
        const FilePickOptions(source: PickerSource.photoLibrary).source,
        PickerSource.photoLibrary,
      );
    });

    test('toString carries the source', () {
      expect(
        _photoInvoiceOptions.toString(),
        contains('source: PickerSource.auto'),
      );
    });
  });

  group('invoice-flow parity through the in-memory adapter (SC-4)', () {
    test('the PDF shape scripts a fully populated descriptor', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(
          FilePickResult(
            files: [
              PickedFile(
                path: '/tmp/invoice-1.pdf',
                name: 'invoice-1.pdf',
                // A real byte size — large PDFs must never degrade to a
                // zero placeholder (spec 002 FR-3).
                size: 5242880,
                mimeType: 'application/pdf',
              ),
            ],
          ),
        );
      final result = await adapter.pickFiles(_pdfInvoiceOptions);
      expect(result.isCanceled, isFalse);
      final file = result.files.single;
      expect(file.path, '/tmp/invoice-1.pdf');
      expect(file.name, 'invoice-1.pdf');
      expect(file.size, 5242880);
      expect(file.size, isNot(0));
      expect(file.mimeType, 'application/pdf');

      // The options must reach the port verbatim — the adapter never
      // rewrites the extension filter.
      expect(adapter.lastPickOptions, same(_pdfInvoiceOptions));
      expect(adapter.lastPickOptions!.allowedExtensions, ['pdf']);
    });

    test('the photo shape accepts heic with full field population', () async {
      final adapter = InMemoryFilePickerAdapter()
        ..setNextPickResult(
          FilePickResult(
            files: [
              PickedFile(
                path: '/tmp/invoice-photo.heic',
                name: 'invoice-photo.heic',
                size: 2457600,
                mimeType: 'image/heic',
              ),
            ],
          ),
        );
      final result = await adapter.pickFiles(_photoInvoiceOptions);
      final file = result.files.single;
      expect(file.name, 'invoice-photo.heic');
      expect(file.size, 2457600);
      expect(file.mimeType, 'image/heic');
      expect(adapter.lastPickOptions!.type, FileType.media);
      expect(adapter.lastPickOptions!.allowedExtensions, [
        'jpg',
        'jpeg',
        'png',
        'heic',
      ]);
    });

    test(
      'a dismissed picker is canceled for both shapes — never an exception',
      () async {
        final adapter = InMemoryFilePickerAdapter();
        // No script = the user dismissed the picker.
        final pdfResult = await adapter.pickFiles(_pdfInvoiceOptions);
        final photoResult = await adapter.pickFiles(_photoInvoiceOptions);
        expect(pdfResult.isCanceled, isTrue);
        expect(pdfResult.files, isEmpty);
        expect(photoResult.isCanceled, isTrue);
        expect(photoResult.files, isEmpty);
      },
    );

    test('the service passes both shapes through unchanged', () async {
      final adapter = InMemoryFilePickerAdapter();
      final picker = FilePickerService(port: adapter);
      await picker.pickFiles(_pdfInvoiceOptions);
      expect(adapter.lastPickOptions!.source, PickerSource.auto);
      await picker.pickFiles(_photoInvoiceOptions);
      expect(adapter.lastPickOptions!.type, FileType.media);
    });
  });
}
