import 'package:flutter_test/flutter_test.dart';
import 'package:public_memory_tracker/app.dart';

void main() {
  testWidgets('App renders header', (tester) async {
    await tester.pumpWidget(const PublicMemoryApp());
    await tester.pump();

    expect(find.textContaining('PUBLIC MEMORY'), findsOneWidget);
  });
}
