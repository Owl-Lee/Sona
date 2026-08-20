import 'package:flutter_test/flutter_test.dart';
import 'package:sonar_vault/features/library/presentation/widgets/track_artwork.dart';

void main() {
  test('keeps short semantic song titles intact', () {
    expect(artworkLabelForTitle('美丽的神话 I'), '美丽的神话');
    expect(artworkLabelForTitle('真的爱你'), '真的爱你');
    expect(artworkLabelForTitle('像我这样的人'), '像我这样的人');
    expect(artworkLabelForTitle('Mei Li De Shen Hua'), 'MEI LI');
  });

  test('removes download noise before building the artwork label', () {
    expect(artworkLabelForTitle('01 - 【4K60FPS】《消愁》'), '消愁');
  });
}
