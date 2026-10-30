// Fleet consistency contract (zik_zak spec 1205, FR-7/FR-9/FR-11).
//
// Every federated member shares the fleet mono version, the `zuraffa`
// constraint moves with it, the README install guide shows it, CI
// exercises every member, and no pubspec points outside the repo (a
// sibling-path override cannot resolve on CI or on a fresh clone).
import 'dart:io';

import 'package:test/test.dart';

const _members = [
  'zuraffa_file_picker',
  'zuraffa_file_picker_platform_interface',
  'zuraffa_file_picker_android',
  'zuraffa_file_picker_ios',
  'zuraffa_file_picker_macos',
];

/// Repo root, as seen from this package's directory (`packages/
/// zuraffa_file_picker`, the working directory of `dart test`).
final Directory _repoRoot = Directory.current.parent.parent;

File _memberPubspec(String member) =>
    File('${_repoRoot.path}/packages/$member/pubspec.yaml');

String _read(File file, String what) {
  expect(file.existsSync(), isTrue, reason: '$what is missing at ${file.path}');
  return file.readAsStringSync();
}

/// The version line of a member's pubspec.
String _versionOf(String member) {
  final text = _read(_memberPubspec(member), '$member pubspec');
  final match = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(text);
  expect(match, isNotNull, reason: '$member pubspec has no version line');
  return match!.group(1)!;
}

void main() {
  test('every federated member carries the same mono version (FR-11)', () {
    final versions = {for (final m in _members) m: _versionOf(m)};
    expect(
      versions.values.toSet(),
      hasLength(1),
      reason:
          'fleet mono version policy: all members at one version, '
          'got $versions',
    );
  });

  test('the family `zuraffa` constraint sits at the fleet version (FR-11)', () {
    final version = _versionOf('zuraffa_file_picker');
    final text = _read(_memberPubspec('zuraffa_file_picker'), 'app pubspec');
    final match = RegExp(
      r'^  zuraffa:\s*\^(\S+)',
      multiLine: true,
    ).firstMatch(text);
    expect(match, isNotNull, reason: 'app pubspec declares no zuraffa pin');
    expect(
      match!.group(1),
      version,
      reason: 'zuraffa constraint must move with the fleet mono version',
    );
  });

  test('README install guide shows the fleet version (FR-9)', () {
    final version = _versionOf('zuraffa_file_picker');
    final readme = _read(File('${_repoRoot.path}/README.md'), 'README');
    expect(
      readme,
      contains('zuraffa_file_picker: ^$version'),
      reason: 'README install snippet must pin the current fleet version',
    );
  });

  test('README reads cold: platform matrix and adoption note (FR-9)', () {
    final readme = _read(File('${_repoRoot.path}/README.md'), 'README');
    expect(readme, contains('## Platform support'));
    expect(readme, contains('## Adoption status'));
  });

  test('CI exercises every federated member (FR-7)', () {
    final workflow = _read(
      File('${_repoRoot.path}/.github/workflows/test.yml'),
      'CI workflow',
    );
    for (final member in _members) {
      expect(
        workflow,
        contains(member),
        reason: 'CI workflow must cover $member',
      );
    }
  });

  test('every member CHANGELOG mentions the fleet version (FR-8)', () {
    final version = _versionOf('zuraffa_file_picker');
    for (final member in _members) {
      final changelog = _read(
        File('${_repoRoot.path}/packages/$member/CHANGELOG.md'),
        '$member changelog',
      );
      expect(
        changelog,
        contains('## $version'),
        reason:
            'pub publish fails validation when the changelog does not '
            'mention the current version',
      );
    }
  });

  test('no pubspec points outside the repo (CI would not resolve)', () {
    final pubspecs = [
      for (final member in _members)
        File('${_repoRoot.path}/packages/$member/pubspec.yaml'),
      File(
        '${_repoRoot.path}/packages/zuraffa_file_picker/example/pubspec.yaml',
      ),
    ];
    for (final pubspec in pubspecs) {
      final text = _read(pubspec, '${pubspec.parent.path.split('/').last} pubspec');
      for (final match in RegExp(r'''path:\s*["']?([^"'\s]+)''').allMatches(
        text,
      )) {
        final resolved =
            Uri.file('${pubspec.parent.path}/').resolve(match.group(1)!);
        expect(
          resolved.toFilePath().startsWith('${_repoRoot.path}/'),
          isTrue,
          reason:
              '${pubspec.path} points outside the repo: '
              '${match.group(1)} resolves to ${resolved.toFilePath()}',
        );
      }
    }
  });
}
