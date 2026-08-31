import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/features/cloud/domain/cloud_library_mirror_plan.dart';

void main() {
  group('cloud library mirror plan', () {
    test('partitions local and cloud hashes into safe mirror actions', () {
      final plan = planCloudLibraryMirror(
        localHashes: {'same', 'upload', 'restore', 'large'},
        activeCloudHashes: {'same', 'remove'},
        recycledCloudHashes: {'restore', 'old-trash'},
        tooLargeLocalHashes: {'large'},
      );

      expect(plan.uploadHashes, {'upload', 'large'});
      expect(plan.restoreHashes, {'restore'});
      expect(plan.recycleHashes, {'remove'});
      expect(plan.unchangedHashes, {'same'});
      expect(plan.tooLargeUploadHashes, {'large'});
      expect(plan.hasChanges, isTrue);
    });

    test('does not touch unrelated tracks already in the recycle bin', () {
      final plan = planCloudLibraryMirror(
        localHashes: {'same'},
        activeCloudHashes: {'same'},
        recycledCloudHashes: {'previously-deleted'},
      );

      expect(plan.hasChanges, isFalse);
      expect(plan.restoreHashes, isEmpty);
      expect(plan.recycleHashes, isEmpty);
    });
  });
}
