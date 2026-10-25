import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/main_scaffold.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initBaseUrl();
  runApp(const SantoriMusicApp());
}

class SantoriMusicApp extends StatelessWidget {
  const SantoriMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<ThemeProvider, AudioPlaybackService>(
          create: (_) => AudioPlaybackService(),
          update: (_, theme, audio) {
            theme.onSleepEnd = () {
              audio?.pause();
            };
            return audio ?? AudioPlaybackService();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          final shade = theme.currentShade;

          return MaterialApp(
            title: 'SANTORI Music',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: shade.desk,
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.inkColor,
                brightness: shade.isDark ? Brightness.dark : Brightness.light,
                surface: shade.paper,
                onSurface: shade.text,
              ),
              textTheme: GoogleFonts.karlaTextTheme().copyWith(
                titleLarge: GoogleFonts.fraunces(
                  color: shade.text,
                  fontWeight: FontWeight.w600,
                ),
                titleMedium: GoogleFonts.fraunces(
                  color: shade.text,
                  fontWeight: FontWeight.w600,
                ),
                bodyLarge: GoogleFonts.karla(color: shade.text),
                bodyMedium: GoogleFonts.karla(color: shade.text),
              ),
            ),
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}
