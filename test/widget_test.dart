import 'package:Bibly/main.dart';
import 'package:Bibly/providers/reading_settings.dart';
import 'package:Bibly/providers/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bibly app renders home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ReadingSettings()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Bibly'), findsOneWidget);
  });
}
