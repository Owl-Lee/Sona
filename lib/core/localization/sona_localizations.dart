import 'package:flutter/widgets.dart';
import 'package:pinyin/pinyin.dart' show ChineseHelper;

/// Sona keeps Simplified Chinese as the source language. Traditional Chinese
/// is derived with the bundled offline dictionary, while English uses reviewed
/// product copy. Missing English entries deliberately fall back to the source
/// text so a new control never becomes blank.
class SonaLocalizations {
  const SonaLocalizations(this.locale);

  final Locale locale;

  static SonaLocalizations of(BuildContext context) =>
      SonaLocalizations(Localizations.localeOf(context));

  String text(String source) {
    if (locale.languageCode == 'en') return _english[source] ?? source;
    if (locale.scriptCode == 'Hant') {
      return ChineseHelper.convertToTraditionalChinese(source);
    }
    return source;
  }
}

extension SonaLocalizationContext on BuildContext {
  String tr(String source) => SonaLocalizations.of(this).text(source);
}

const _english = <String, String>{
  '设置': 'Settings',
  '外观与播放器': 'Appearance & player',
  '账号与云同步': 'Account & cloud sync',
  '登录、头像与跨设备同步': 'Sign in, profile and device sync',
  '语言': 'Languages',
  '语言与显示文字': 'Language and display text',
  '简体中文': 'Simplified Chinese',
  '繁體中文': 'Traditional Chinese',
  '英文': 'English',
  '选择界面语言': 'Choose interface language',
  '切换后立即应用，并在下次启动时保留。':
      'Changes apply immediately and are kept for the next launch.',
  '当前语言': 'Current language',
  '存储与数据': 'Storage & data',
  '此设备': 'this device',
  '关于': 'About',
  '返回设置': 'Back to Settings',
  '此设备数据库': 'On-device database',
  '正在读取数据库位置…': 'Reading database location…',
  '音频声纹识别': 'Audio fingerprint recognition',
  '未配置时仍可使用标签、文件名和 MusicBrainz 后备校准':
      'Tags, filenames and MusicBrainz remain available without a key',
  'AcoustID 已配置 · 声纹不命中时自动回退公开曲库':
      'AcoustID configured · falls back to the public catalog when needed',
  '配置免费 Key': 'Configure free key',
  '已启用': 'Enabled',
  '版本 0.4.26 · Android / Windows': 'Version 0.4.26 · Android / Windows',
  '首页': 'Home',
  '曲库': 'Library',
  '本地曲库': 'Local library',
  '歌单': 'Playlists',
  '我的歌单': 'My playlists',
  '我的收藏': 'Favorites',
  '最近播放': 'Recently played',
  'MV 专区': 'Music videos',
  '听歌排行': 'Listening stats',
  '我的音乐': 'My music',
  '常用歌单': 'Pinned playlists',
  '选择常用歌单': 'Choose pinned playlists',
  '取消': 'Cancel',
  '保存': 'Save',
  '折叠': 'Collapse',
  '展开': 'Expand',
  '首': ' tracks',
  '我的背景': 'My background',
};
