import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/core/utils/latest_request_gate.dart';

void main() {
  test(
    'violent repeated taps leave only the last playback request current',
    () {
      final gate = LatestRequestGate();
      final requests = <int>[];

      for (var index = 0; index < 1000; index++) {
        requests.add(gate.begin());
      }

      expect(gate.isCurrent(requests.last), isTrue);
      expect(requests.take(requests.length - 1).every(gate.isCurrent), isFalse);
      expect(requests.take(requests.length - 1).where(gate.isCurrent), isEmpty);
    },
  );

  test('a newer cloud click invalidates every pending older request', () {
    final gate = LatestRequestGate();
    final cloudA = gate.begin();
    final cloudB = gate.begin();
    final cloudC = gate.begin();

    expect(gate.isCurrent(cloudA), isFalse);
    expect(gate.isCurrent(cloudB), isFalse);
    expect(gate.isCurrent(cloudC), isTrue);
  });
}
