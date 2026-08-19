import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/library_controller.dart';
import '../domain/playlist_info.dart';
import '../domain/track.dart';
import '../domain/track_identification.dart';
import '../../player/application/player_controller.dart';
import 'widgets/track_artwork.dart';

enum TrackMenuSource { library, recent, ranking, playlist }

Future<void> importMusic(
  BuildContext context,
  WidgetRef ref, {
  required bool directory,
}) async {
  final controller = ref.read(libraryControllerProvider.notifier);
  final summary = directory
      ? await controller.importDirectory()
      : await controller.importFiles();
  if (!context.mounted || summary == null) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(summary.message)));
}

Future<void> playTrack(
  WidgetRef ref,
  Track track,
  List<Track> queue, {
  String source = '本地曲库',
}) async {
  // PlayerController owns the media-type route. That keeps a click from the
  // library, queue drawer, or next/previous buttons on one safe MV hand-off.
  await ref
      .read(playerControllerProvider.notifier)
      .playTrack(track, queue, source: source);
}

/// Shared song actions for mouse right-click on Windows and long-press on
/// touch devices.  The original media file is never removed from disk.
Future<void> showTrackContextMenu(
  BuildContext context,
  WidgetRef ref,
  Track track, {
  TrackMenuSource source = TrackMenuSource.library,
  Offset? position,
  Future<void> Function()? onRemoveFromPlaylist,
}) async {
  final action = await _chooseTrackAction(
    context,
    track,
    source: source,
    position: position,
  );
  if (action == null || !context.mounted) return;

  final library = ref.read(libraryControllerProvider.notifier);
  switch (action) {
    case 'identify':
      await _identifyTrack(context, ref, track);
    case 'favorite':
      await library.toggleFavorite(track);
    case 'playlist':
      await _addTrackToPlaylist(context, ref, track);
    case 'source':
      if (source == TrackMenuSource.recent) {
        await library.clearFromRecentlyPlayed(track);
      } else if (source == TrackMenuSource.ranking) {
        await library.clearFromRankings(track);
      } else if (source == TrackMenuSource.playlist) {
        await onRemoveFromPlaylist?.call();
      }
    case 'library':
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('从本地曲库移除？'),
          content: Text('“${track.title}”将不再显示在 Sona 中，电脑里的原始文件不会被删除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.remove_circle_outline_rounded),
              label: const Text('移除'),
            ),
          ],
        ),
      );
      if (confirmed == true) await library.removeTrack(track);
    default:
      return;
  }
}

Future<String?> _chooseTrackAction(
  BuildContext context,
  Track track, {
  required TrackMenuSource source,
  Offset? position,
}) {
  final items = _trackMenuItems(track, source);
  final overlay = Navigator.of(context).overlay;
  if (position != null &&
      overlay != null &&
      MediaQuery.sizeOf(context).width >= 760) {
    final overlayBox = overlay.context.findRenderObject() as RenderBox;
    return showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 1, 1),
        Offset.zero & overlayBox.size,
      ),
      items: items
          .map(
            (item) => PopupMenuItem<String>(
              value: item.$1,
              child: Row(
                children: [
                  Icon(
                    item.$2,
                    color: item.$1 == 'library' ? AppColors.accent : null,
                  ),
                  const SizedBox(width: 10),
                  Text(item.$3),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: TrackArtwork(track: track, size: 46, borderRadius: 12),
              title: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(),
            ...items.map(
              (item) => ListTile(
                leading: Icon(
                  item.$2,
                  color: item.$1 == 'library' ? AppColors.accent : null,
                ),
                title: Text(item.$3),
                onTap: () => Navigator.pop(sheetContext, item.$1),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

List<(String, IconData, String)> _trackMenuItems(
  Track track,
  TrackMenuSource source,
) => [
  ('identify', Icons.auto_fix_high_rounded, 'AI 识别歌曲信息'),
  (
    'favorite',
    track.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    track.isFavorite ? '取消收藏' : '收藏',
  ),
  ('playlist', Icons.playlist_add_rounded, '加入歌单'),
  if (source == TrackMenuSource.recent)
    ('source', Icons.history_toggle_off_rounded, '从最近播放中移除'),
  if (source == TrackMenuSource.ranking)
    ('source', Icons.leaderboard_outlined, '从听歌排行中移除'),
  if (source == TrackMenuSource.playlist)
    ('source', Icons.playlist_remove_rounded, '从歌单中移除'),
  ('library', Icons.remove_circle_outline_rounded, '从本地曲库移除'),
];

Future<void> _identifyTrack(
  BuildContext context,
  WidgetRef ref,
  Track track,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 16),
          Flexible(child: Text('正在分析标签、文件名和公开曲库…')),
        ],
      ),
    ),
  );

  TrackIdentificationResult result;
  try {
    result = await ref
        .read(libraryControllerProvider.notifier)
        .identifyTrack(track);
  } catch (_) {
    result = const TrackIdentificationResult(message: '识别过程中出现异常，原歌曲信息没有被修改。');
  }
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  final candidate = result.candidate;
  if (candidate == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result.message)));
    return;
  }

  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_fix_high_rounded),
          SizedBox(width: 10),
          Text('识别结果'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 16),
            _MetadataComparisonRow(
              label: '歌曲',
              before: track.title,
              after: candidate.title,
            ),
            _MetadataComparisonRow(
              label: '歌手',
              before: track.artist,
              after: candidate.artist,
            ),
            _MetadataComparisonRow(
              label: '专辑',
              before: track.album,
              after: candidate.album.isEmpty ? '未提供' : candidate.album,
            ),
            const SizedBox(height: 12),
            Text(
              '${candidate.source} · 可信度 ${(candidate.confidence * 100).round()}%',
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              candidate.explanation,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('保留原信息'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(dialogContext, true),
          icon: const Icon(Icons.check_rounded),
          label: const Text('应用校准'),
        ),
      ],
    ),
  );
  if (accepted != true || !context.mounted) return;
  await ref
      .read(libraryControllerProvider.notifier)
      .applyIdentification(track, candidate);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已更新为“${candidate.title}”－${candidate.artist}')),
  );
}

class _MetadataComparisonRow extends StatelessWidget {
  const _MetadataComparisonRow({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              before == after ? after : '$before  →  $after',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _addTrackToPlaylist(
  BuildContext context,
  WidgetRef ref,
  Track track,
) async {
  final playlists = ref.read(libraryControllerProvider).playlists;
  if (playlists.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('请先在“歌单”中创建一个歌单。')));
    return;
  }
  final selected = await showDialog<PlaylistInfo>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('加入歌单'),
      children: playlists
          .map(
            (playlist) => SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, playlist),
              child: Text(playlist.name),
            ),
          )
          .toList(growable: false),
    ),
  );
  if (selected == null) return;
  final added = await ref
      .read(libraryControllerProvider.notifier)
      .addTrackToPlaylist(selected, track);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(added ? '已加入“${selected.name}”' : '这首歌已经在该歌单中')),
  );
}
