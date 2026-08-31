class CloudLibraryMirrorPlan {
  const CloudLibraryMirrorPlan({
    required this.uploadHashes,
    required this.restoreHashes,
    required this.recycleHashes,
    required this.unchangedHashes,
    required this.tooLargeUploadHashes,
  });

  final Set<String> uploadHashes;
  final Set<String> restoreHashes;
  final Set<String> recycleHashes;
  final Set<String> unchangedHashes;
  final Set<String> tooLargeUploadHashes;

  int get uploadCount => uploadHashes.length;
  int get restoreCount => restoreHashes.length;
  int get recycleCount => recycleHashes.length;
  int get unchangedCount => unchangedHashes.length;
  int get tooLargeCount => tooLargeUploadHashes.length;

  bool get hasChanges =>
      uploadHashes.isNotEmpty ||
      restoreHashes.isNotEmpty ||
      recycleHashes.isNotEmpty;
}

CloudLibraryMirrorPlan planCloudLibraryMirror({
  required Set<String> localHashes,
  required Set<String> activeCloudHashes,
  required Set<String> recycledCloudHashes,
  Set<String> tooLargeLocalHashes = const {},
}) {
  final upload = localHashes
      .difference(activeCloudHashes)
      .difference(recycledCloudHashes);
  return CloudLibraryMirrorPlan(
    uploadHashes: Set.unmodifiable(upload),
    restoreHashes: Set.unmodifiable(
      localHashes.intersection(recycledCloudHashes),
    ),
    recycleHashes: Set.unmodifiable(activeCloudHashes.difference(localHashes)),
    unchangedHashes: Set.unmodifiable(
      localHashes.intersection(activeCloudHashes),
    ),
    tooLargeUploadHashes: Set.unmodifiable(
      upload.intersection(tooLargeLocalHashes),
    ),
  );
}
