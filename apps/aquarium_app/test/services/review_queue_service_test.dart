// Tests for ReviewQueueService.
//
// Run: flutter test test/services/review_queue_service_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/review_queue_service.dart';

void main() {
  group('ReviewQueueService.generateNotificationMessage', () {
    test('uses quiet plain-text reminder copy', () {
      expect(
        ReviewQueueService.generateNotificationMessage(0),
        'All caught up!',
      );
      expect(
        ReviewQueueService.generateNotificationMessage(1),
        '1 card needs review',
      );
      expect(
        ReviewQueueService.generateNotificationMessage(5),
        '5 cards need review',
      );
      expect(
        ReviewQueueService.generateNotificationMessage(10),
        '10 cards waiting. Keep your knowledge fresh',
      );
      expect(
        ReviewQueueService.generateNotificationMessage(12),
        '12 cards need attention. Time to practice',
      );
    });
  });
}
