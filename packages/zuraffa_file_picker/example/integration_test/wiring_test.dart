import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zuraffa/zuraffa.dart' show GetIt;
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

/// Real-device characterization of the zuraffa_file_picker federated
/// plugin.
///
/// This runs on a physical OS (macOS / Android / iOS), not the in-memory
/// Dart adapter. Every port operation opens a real picker dialog — which
/// no automated run can dismiss — so this suite stays non-blocking and
/// proves the part that can fail silently: that the federated platform
/// package registered, the platform instance was swapped, and the
/// GetIt-registered stack resolves the real method-channel port rather
/// than the in-memory fallback.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('zuraffa_file_picker — real native plugin wiring', () {
    testWidgets('the federated adapter is registered and backed the stack', (
      tester,
    ) async {
      final getIt = GetIt.asNewInstance();
      registerFilePickerDependencies(getIt);

      final port = getIt<FilePickerPort>();
      expect(port, isA<MethodChannelFilePickerAdapter>());
      expect(
        ZuraffaFilePickerPlatform.instance,
        isA<MethodChannelZuraffaFilePicker>(),
      );
      expect(getIt<FilePickerService>().port, same(port));

      // The pure-Dart fallback did NOT answer: the default platform
      // instance was replaced at plugin registration time.
      expect(
        ZuraffaFilePickerPlatform.instance,
        isNot(isA<DefaultZuraffaFilePickerPlatform>()),
      );
    });
  });
}
