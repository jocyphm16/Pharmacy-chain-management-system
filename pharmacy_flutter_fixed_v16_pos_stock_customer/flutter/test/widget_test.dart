import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fl_quan_li_ban_thuoc/main.dart';

void main() {
  testWidgets('App starts successfully test', (WidgetTester tester) async {
    // Khởi chạy App của chúng ta (bỏ chữ const đi)
    await tester.pumpWidget(MyApp());

    // Vì app của bạn bắt đầu bằng SplashScreen có chứa vòng xoay load (CircularProgressIndicator)
    // Nên chúng ta sẽ test xem vòng xoay đó có xuất hiện trên màn hình hay không.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}