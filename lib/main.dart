import 'package:better_libria/src/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:better_libria/src/themes/themes_data.dart';
import 'package:provider/provider.dart';
import 'package:better_libria/src/loadingScreen.dart';


void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const BetterLibria(),
  ));
}

class BetterLibria extends StatelessWidget {
  const BetterLibria({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: Provider.of<ThemeProvider>(context).themeMode,
        home: const LoadingScreen(),
      );
  }
}
