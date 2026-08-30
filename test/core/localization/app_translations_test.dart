import 'package:citieswalk/core/localization/localized_material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('localizes ordinary app text in Simplified Chinese', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        supportedLocales: [Locale('zh')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Text('Profile'),
      ),
    );

    expect(find.text('个人资料'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('localizes dynamic count patterns in Bahasa Melayu', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ms'),
        supportedLocales: [Locale('ms')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Text('7 reviews'),
      ),
    );

    expect(find.text('7 ulasan'), findsOneWidget);
  });
}
