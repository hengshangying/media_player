import 'package:flutter_test/flutter_test.dart';
import 'package:media_player/models/video_item.dart';

void main() {
  test('VideoItem duration label', () {
    final v = VideoItem(id: '1', title: 't', type: 'movie', durationSec: 125);
    expect(v.durationLabel, '02:05');
  });
}
