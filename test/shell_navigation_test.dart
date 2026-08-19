import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/features/shell/application/shell_navigation.dart';

void main() {
  test('Android 仅允许从首页且无临时状态时退出', () {
    expect(canExitMobileShell(destination: 0, selectionActive: false), isTrue);
    for (final destination in [1, 2, 3, 4]) {
      expect(
        canExitMobileShell(destination: destination, selectionActive: false),
        isFalse,
      );
    }
    expect(canExitMobileShell(destination: 1, selectionActive: true), isFalse);
  });
}
