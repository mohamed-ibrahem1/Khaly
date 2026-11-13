import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'providers/bill_provider.dart';
import 'views/home_screen.dart';

void main() => runApp(const TabSplitApp());

class TabSplitApp extends StatelessWidget {
  const TabSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BillProvider>(
      create: (_) => BillProvider()..loadFrequentFriends(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          title: 'Khaly',
          theme: AppTheme.darkTheme,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
