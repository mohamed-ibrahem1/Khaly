import 'package:flutter_test/flutter_test.dart';

import 'package:khaly/main.dart';

void main() {
  testWidgets('shows the empty bill state', (tester) async {
    await tester.pumpWidget(const TabSplitApp());
    await tester.pump();

    expect(find.text('خلّى'), findsOneWidget);
    expect(find.text('اضغط + لإضافة شخص'), findsOneWidget);
  });
}
