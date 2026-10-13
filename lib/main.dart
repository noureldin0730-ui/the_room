import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/room_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const TheRoomApp());
}

class TheRoomApp extends StatelessWidget {
  const TheRoomApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THE ROOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
          ),
          child: child!,
        );
      },
      home: const StartScreen(),
    );
  }
}

// ═══════════ الألوان — رعب ═══════════
class P {
  static const black = Color(0xFF000000);
  static const dark = Color(0xFF0A0A0A);
  static const dim = Color(0xFF1A1A1A);
  static const line = Color(0xFF2A2A2A);
  static const gray = Color(0xFF6A6A6A);
  static const white = Color(0xFFE0E0E0);
  static const blood = Color(0xFF8B0000);
  static const rare = Color(0xFFC1272D);
  static const gold = Color(0xFFB8945C);
}

// ═══════════ شاشة البداية ═══════════
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});
  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flicker;

  @override
  void initState() {
    super.initState();
    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoomScreen(roomId: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _flicker,
                builder: (context, child) {
                  final opacity = 0.7 + (_flicker.value * 0.3);
                  return Opacity(
                    opacity: opacity,
                    child: const Text(
                      'THE ROOM',
                      style: TextStyle(
                        color: P.rare,
                        fontSize: 56,
                        letterSpacing: 16,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: P.blood,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(width: 100, height: 1, color: P.blood),
              const SizedBox(height: 16),
              const Text(
                'أنت مش لوحدك',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: P.gray,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 80),
              GestureDetector(
                onTap: _start,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: P.blood, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: P.blood.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'ادخل',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: P.white,
                      fontSize: 20,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Nour Eldin',
                  style: TextStyle(
                    color: P.gray,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}