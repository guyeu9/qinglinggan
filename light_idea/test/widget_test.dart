import 'package:flutter_test/flutter_test.dart';
import 'package:light_idea/main.dart';

void main() {
  testWidgets('App should initialize successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LightIdeaApp());

    expect(find.text('轻灵感'), findsOneWidget);
    expect(find.text('数据库初始化成功！'), findsOneWidget);
  });
}
