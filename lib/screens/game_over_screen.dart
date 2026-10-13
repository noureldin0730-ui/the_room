import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class P {
  static const black = Color(0xFF000000);
  static const dark = Color(0xFF0A0A0A);
  static const gray = Color(0xFF6A6A6A);
  static const white = Color(0xFFE0E0E0);
  static const blood = Color(0xFF8B0000);
  static const rare = Color(0xFFC1272D);
}

class GameOverScreen extends StatefulWidget {
  final int roomId;
  final String reason;
  final VoidCallback onRetry;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const GameOverScreen({
    super.key,
    required this.roomId,
    required this.reason,
    required this.onRetry,
    required this.onRestart,
    required this.onExit,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flicker;

  @override
  void initState() {
    super.initState();
    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
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
                  return Opacity(
                    opacity: 0.6 + (_flicker.value * 0.4),
                    child: const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: P.rare,
                        fontSize: 60,
                        letterSpacing: 12,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: P.blood,
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 2,
                color: P.blood,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.reason,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: P.white,
                    fontSize: 15,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // الأزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                    label: 'كمّل من الغرفة',
                    onTap: widget.onRetry,
                    color: P.rare,
                  ),
                  const SizedBox(width: 16),
                  _buildButton(
                    label: 'من الغرفة 1',
                    onTap: widget.onRestart,
                    color: P.dark,
                  ),
                  const SizedBox(width: 16),
                  _buildButton(
                    label: 'خروج',
                    onTap: widget.onExit,
                    color: P.dark,
                  ),
                ],
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

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: P.white,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}