import 'package:zuraffa/zuraffa.dart';

import '../entities/file_pick_options/file_pick_options.dart';
import '../entities/file_pick_result/file_pick_result.dart';
import '../file_picker_port.dart';

/// File picking as a Zuraffa use case (FR-003): pick files through the
/// [FilePickerPort], honoring cancellation. Pure — no statics, no
/// Flutter.
class PickFilesUseCase extends UseCase<FilePickResult, FilePickOptions> {
  PickFilesUseCase(this._port);

  final FilePickerPort _port;

  @override
  Future<FilePickResult> execute(
    FilePickOptions params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    return _port.pickFiles(params);
  }
}
