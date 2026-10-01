import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/news_feed_screen.dart';
import 'services/news_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var apiKey = '';
  try {
    apiKey = _readApiKey(await rootBundle.loadString('.env'));
  } catch (_) {
    // The app still starts and presents a useful configuration error.
  }

  runApp(EmpautaApp(apiKey: apiKey));
}

String _readApiKey(String envFile) {
  for (final line in envFile.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final separator = trimmed.indexOf('=');
    if (separator < 0) continue;
    if (trimmed.substring(0, separator).trim() == 'NYT_API_KEY') {
      return trimmed.substring(separator + 1).trim();
    }
  }
  return '';
}

class EmpautaApp extends StatelessWidget {
  EmpautaApp({super.key, NewsRepository? repository, String apiKey = ''})
    : repository = repository ?? NyTimesNewsRepository(apiKey: apiKey);

  final NewsRepository repository;

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFFE34B36);
    const paperColor = Color(0xFFF7F4EE);

    return MaterialApp(
      title: 'empauta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paperColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.light,
          surface: paperColor,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1D211F),
          displayColor: const Color(0xFF1D211F),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: const Color(0xE61A1C1B),
          indicatorColor: brandColor,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? Colors.white
                  : Colors.white70,
            );
          }),
        ),
      ),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: NewsFeedScreen(repository: repository),
      ),
    );
  }
}
