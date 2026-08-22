import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/core/widgets/whole_item_viewport.dart';
import 'package:sonar_vault/features/player/presentation/vinyl_record.dart';

void main() {
  testWidgets('fixed list viewport only exposes complete item extents', (
    tester,
  ) async {
    const childKey = ValueKey('whole-list-child');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 539,
            child: WholeItemViewport(
              itemExtent: 66,
              child: ColoredBox(key: childKey, color: Colors.blue),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)).height, 528);
  });

  testWidgets('mobile list surface fills space around complete rows', (
    tester,
  ) async {
    const surfaceKey = ValueKey('mobile-list-surface');
    const listKey = ValueKey('mobile-list-viewport');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 539,
            child: Material(
              key: surfaceKey,
              child: WholeItemViewport(
                itemExtent: 72,
                child: ColoredBox(key: listKey, color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(surfaceKey)).height, 539);
    expect(tester.getSize(find.byKey(listKey)).height, 504);
  });

  testWidgets('vinyl layout center is not shifted by the tonearm', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: VinylRecord(
            track: null,
            size: 220,
            turns: AlwaysStoppedAnimation<double>(0),
            isPlaying: false,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(VinylRecord)), const Size(220, 220));
  });
}
