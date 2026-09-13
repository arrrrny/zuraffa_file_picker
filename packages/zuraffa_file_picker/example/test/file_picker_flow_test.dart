// Widget test as executable documentation: drives the complete picker flow
// — every port operation once over the simulator, asserting outcomes
// (including cancellation and the typed error path).
//
// The live mode is never invoked here (it would open a real OS dialog);
// the integration test proves its wiring instead.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_file_picker/zuraffa_file_picker.dart';
import 'package:zuraffa_file_picker_platform_interface/zuraffa_file_picker_platform_interface.dart';

import 'package:example/main.dart';
import 'package:example/src/file_picker_home.dart';
import 'package:example/src/picker_controller.dart';

void main() {
  late InMemoryFilePickerAdapter simulatorAdapter;

  setUp(() {
    simulatorAdapter = InMemoryFilePickerAdapter();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // Tall surface: the home screen is a long scrolling list and ListView
    // only builds visible children.
    tester.view.physicalSize = const Size(1200, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FilePickerApp(simulatorAdapter: simulatorAdapter),
    );
    await tester.pumpAndSettle();
  }

  Future<void> switchToSimulator(WidgetTester tester) async {
    await tester.tap(find.text('Simulator'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the three operation panels in live mode by default', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('zuraffa_file_picker'), findsOneWidget);
    expect(find.text('pickFiles'), findsOneWidget);
    expect(find.text('saveFile'), findsOneWidget);
    expect(find.text('pickDirectory'), findsOneWidget);
    // The simulator seams are hidden in live mode.
    expect(find.text('Simulator seams'), findsNothing);
  });

  testWidgets('simulator pick flow: staged file renders with metadata', (
    tester,
  ) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.byKey(const Key('stage-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    expect(find.text('picked-file-1.png'), findsOneWidget);
    expect(find.text('1.0 KB · image/png'), findsOneWidget);
    expect(find.text('pickFiles → 1 file(s): picked-file-1.png'), findsOneWidget);
    // The adapter recorded the options the UI sent.
    expect(simulatorAdapter.lastPickOptions!.type, FileType.any);
  });

  testWidgets('simulator canceled pick renders the canceled placeholder', (
    tester,
  ) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    // No script staged: the adapter's default outcome is "canceled".
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('pickFiles — canceled (empty result / null path'),
      findsOneWidget,
    );
    expect(find.text('pickFiles → canceled'), findsOneWidget);
  });

  testWidgets('multiple + initial directory reach the recorded options', (
    tester,
  ) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.text('Multiple'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Initial directory (optional)').first,
      '/simulated/inbox',
    );
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    final options = simulatorAdapter.lastPickOptions!;
    expect(options.multiple, isTrue);
    expect(options.initialDirectory, '/simulated/inbox');
  });

  testWidgets('custom type without extensions surfaces the typed error '
      'verbatim', (tester) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.byType(DropdownButton<FileType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('custom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    // The banner and the flow-log record both carry the verbatim failure.
    expect(
      find.textContaining('missing_allowed_extensions'),
      findsExactly(2),
    );

    // Dismissing the banner clears it; the flow log keeps the record.
    await tester.tap(find.byKey(const Key('error-dismiss')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('error-dismiss')), findsNothing);
    // The flow log keeps the record: exactly one match remains.
    expect(
      find.textContaining('missing_allowed_extensions'),
      findsExactly(1),
    );
  });

  testWidgets('custom type with extension chips sends them to the port', (
    tester,
  ) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.byType(DropdownButton<FileType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('custom').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('.pdf'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    expect(simulatorAdapter.lastPickOptions!.allowedExtensions, ['pdf']);
    // The typed failure is gone — validation passed.
    expect(find.textContaining('missing_allowed_extensions'), findsNothing);
  });

  testWidgets('simulator save flow: staged path renders, then cancels', (
    tester,
  ) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.byKey(const Key('stage-save-path')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-file-run')));
    await tester.pumpAndSettle();
    expect(find.text('/simulated/report.txt'), findsOneWidget);
    expect(find.text('saveFile → /simulated/report.txt'), findsOneWidget);

    // One-shot script consumed: the next save is a cancellation.
    await tester.tap(find.byKey(const Key('save-file-run')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('saveFile — canceled (empty result / null path'),
      findsOneWidget,
    );
  });

  testWidgets('simulator directory flow: staged path renders', (tester) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    await tester.tap(find.byKey(const Key('stage-directory')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-directory-run')));
    await tester.pumpAndSettle();

    expect(find.text('/simulated/documents'), findsOneWidget);
    expect(find.text('pickDirectory → /simulated/documents'), findsOneWidget);
  });

  testWidgets('flow log renders the running record', (tester) async {
    await pumpApp(tester);
    await switchToSimulator(tester);

    expect(find.text('Flow log'), findsOneWidget);
    expect(find.text('No operations yet — pick, save or browse to fill the '
        'log.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stage-file')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pick-files-run')));
    await tester.pumpAndSettle();

    expect(
      find.text('No operations yet — pick, save or browse to fill the log.'),
      findsNothing,
    );
  });

  testWidgets('the controller routes live mode to the injected service', (
    tester,
  ) async {
    final livePort = MethodChannelFilePickerAdapter(
      platform: DefaultZuraffaFilePickerPlatform(),
    );
    await tester.pumpWidget(
      FilePickerApp(liveService: FilePickerService(port: livePort)),
    );
    await tester.pumpAndSettle();

    final home = tester.state<FilePickerHomeState>(
      find.byType(FilePickerHome),
    );
    expect(home.controller.service.port, same(livePort));
    expect(home.controller.mode, PickerMode.live);
  });
}
