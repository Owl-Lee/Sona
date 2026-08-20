import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/core/localization/sona_localizations.dart';
import 'package:sonar_vault/features/settings/application/language_controller.dart';

void main() {
  test('resolves all persisted language values', () {
    expect(AppLanguage.fromStorage('zh-Hans'), AppLanguage.simplifiedChinese);
    expect(AppLanguage.fromStorage('zh-Hant'), AppLanguage.traditionalChinese);
    expect(AppLanguage.fromStorage('en'), AppLanguage.english);
    expect(AppLanguage.fromStorage('damaged'), AppLanguage.simplifiedChinese);
  });

  test('localizes core navigation and settings copy', () {
    expect(
      const SonaLocalizations(Locale('en')).text('外观与播放器'),
      'Appearance & player',
    );
    expect(
      const SonaLocalizations(
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ).text('设置'),
      '設置',
    );
    expect(const SonaLocalizations(Locale('zh')).text('设置'), '设置');
  });
}
