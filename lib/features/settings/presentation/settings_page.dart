import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../account/presentation/account_sync_card.dart';
import '../../library/application/library_controller.dart';
import '../application/appearance_controller.dart';
import 'widgets/appearance_picker.dart';

enum _SettingsSection { root, appearance, account, storage, about }

/// The shell owns system-back and tab switching, while this page owns the
/// concrete secondary screen. Keeping only the depth public lets the shell
/// reset Settings without leaking its internal menu model.
final settingsDetailOpenProvider = StateProvider<bool>((ref) => false);

/// A shell-level request for the account subpage. The settings page keeps its
/// concrete route private, while callers can still open this destination
/// directly instead of first landing on the settings root.
final settingsAccountRequestProvider = StateProvider<int>((ref) => 0);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  _SettingsSection _section = _SettingsSection.root;
  var _lastAccountRequest = 0;

  void _open(_SettingsSection section) {
    setState(() {
      _section = section;
    });
    ref.read(settingsDetailOpenProvider.notifier).state = true;
  }

  void _back() {
    setState(() {
      _section = _SettingsSection.root;
    });
    ref.read(settingsDetailOpenProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final accountRequest = ref.watch(settingsAccountRequestProvider);
    if (accountRequest != _lastAccountRequest) {
      _lastAccountRequest = accountRequest;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open(_SettingsSection.account);
      });
    }
    ref.listen<bool>(settingsDetailOpenProvider, (previous, next) {
      if (!next && _section != _SettingsSection.root && mounted) {
        setState(() {
          _section = _SettingsSection.root;
        });
      }
    });
    final appearance = ref.watch(appearanceControllerProvider);
    final library = ref.watch(libraryControllerProvider);
    final lightForeground =
        !appearance.usesCustom && appearance.preset.prefersLightHomeForeground;
    final foreground = lightForeground ? Colors.white : AppColors.ink;

    return SafeArea(
      child: RepaintBoundary(
        child: switch (_section) {
          _SettingsSection.root => _SettingsRoot(
            foreground: foreground,
            lightForeground: lightForeground,
            appearanceName: appearance.usesCustom
                ? '我的背景'
                : appearance.preset.name,
            onOpen: _open,
          ),
          _SettingsSection.appearance => _SettingsDetailPage(
            title: '外观与播放器',
            foreground: foreground,
            lightForeground: lightForeground,
            onBack: _back,
            child: const _SettingsPanel(
              padding: EdgeInsets.all(16),
              child: AppearancePicker(),
            ),
          ),
          _SettingsSection.account => _SettingsDetailPage(
            title: '账号与云同步',
            foreground: foreground,
            lightForeground: lightForeground,
            onBack: _back,
            child: const AccountSyncCard(),
          ),
          _SettingsSection.storage => _SettingsDetailPage(
            title: '存储与数据',
            foreground: foreground,
            lightForeground: lightForeground,
            onBack: _back,
            child: _StoragePanel(databasePath: library.databasePath),
          ),
          _SettingsSection.about => _SettingsDetailPage(
            title: '关于',
            foreground: foreground,
            lightForeground: lightForeground,
            onBack: _back,
            child: const _AboutPanel(),
          ),
        },
      ),
    );
  }
}

class _SettingsRoot extends StatelessWidget {
  const _SettingsRoot({
    required this.foreground,
    required this.lightForeground,
    required this.appearanceName,
    required this.onOpen,
  });

  final Color foreground;
  final bool lightForeground;
  final String appearanceName;
  final ValueChanged<_SettingsSection> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth >= 1180
            ? 1040.0
            : double.infinity;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 36),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设置',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      shadows: lightForeground
                          ? const [
                              Shadow(color: Colors.black38, blurRadius: 10),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SettingsMenu(
                    children: [
                      _SettingsMenuRow(
                        icon: Icons.palette_outlined,
                        title: '外观与播放器',
                        subtitle: appearanceName,
                        onTap: () => onOpen(_SettingsSection.appearance),
                      ),
                      _SettingsMenuRow(
                        icon: Icons.cloud_outlined,
                        title: '账号与云同步',
                        subtitle: '登录、头像与跨设备同步',
                        onTap: () => onOpen(_SettingsSection.account),
                      ),
                      _SettingsMenuRow(
                        icon: Icons.storage_rounded,
                        title: '存储与数据',
                        subtitle: 'SQLite · 此设备',
                        onTap: () => onOpen(_SettingsSection.storage),
                      ),
                      _SettingsMenuRow(
                        icon: Icons.info_outline_rounded,
                        title: '关于',
                        subtitle: 'Sona 0.4.26',
                        onTap: () => onOpen(_SettingsSection.about),
                        divider: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsDetailPage extends StatelessWidget {
  const _SettingsDetailPage({
    required this.title,
    required this.foreground,
    required this.lightForeground,
    required this.onBack,
    required this.child,
  });

  final String title;
  final Color foreground;
  final bool lightForeground;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Secondary settings pages should grow with the desktop window.  The
        // appearance grid in particular needs this width to add columns when
        // the window is maximised.
        const maxWidth = double.infinity;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 36),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: '返回设置',
                          onPressed: onBack,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w900,
                                shadows: lightForeground
                                    ? const [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  child,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SettingsPanel(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  const _SettingsMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.divider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.textSecondary, size: 23),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (divider) const Divider(height: 1, indent: 56, endIndent: 16),
      ],
    );
  }
}

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceControllerProvider);
    return LiquidGlass(
      borderRadius: 22,
      blur: 18,
      tint: appearance.accent,
      child: Container(width: double.infinity, padding: padding, child: child),
    );
  }
}

class _StoragePanel extends StatelessWidget {
  const _StoragePanel({required this.databasePath});

  final String databasePath;

  @override
  Widget build(BuildContext context) {
    return _SettingsPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.storage_rounded, color: AppColors.lavender),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '此设备数据库',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                SelectableText(
                  databasePath.isEmpty ? '正在读取数据库位置…' : databasePath,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _Badge('SQLite'),
        ],
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return const _SettingsPanel(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.accent,
            child: Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sona',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '版本 0.4.26 · Android / Windows',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          _Badge('Beta'),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
