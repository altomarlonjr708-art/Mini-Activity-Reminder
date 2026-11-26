import 'package:actmind/main.dart';
import 'package:actmind/ui/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ActMind shell shows primary navigation', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const ActMindApp(),
      ),
    );

    expect(find.text('ActMind'), findsOneWidget);
    expect(find.text('Tasks'), findsAtLeastNWidgets(1));
    expect(find.text('Calendar'), findsAtLeastNWidgets(1));
    expect(find.text('Stats'), findsAtLeastNWidgets(1));
    expect(find.text('Settings'), findsAtLeastNWidgets(1));
  });
}
