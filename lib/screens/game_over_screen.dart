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

  void _handleTap(VoidCallback action) {
    HapticFeedback.mediumImpact();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ───── GAME OVER ─────
            AnimatedBuilder(
              animation: _flicker,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.6 + (_flicker.value * 0.4),
                  child: const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: P.rare,
                      fontSize: 52,
                      letterSpacing: 10,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(color: P.blood, blurRadius: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(width: 80, height: 2, color: P.blood),
            const SizedBox(height: 20),

            // ───── السبب ─────
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

            const Spacer(flex: 2),

            // ───── الأزرار ─────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton(
                    label: 'كمّل من الغرفة',
                    onTap: () => _handleTap(widget.onRetry),
                    color: P.rare,
                    filled: true,
                  ),
                  const SizedBox(width: 14),
                  _buildButton(
                    label: 'من الغرفة 1',
                    onTap: () => _handleTap(widget.onRestart),
                    color: P.gray,
                    filled: false,
                  ),
                  const SizedBox(width: 14),
                  _buildButton(
                    label: 'خروج',
                    onTap: () => _handleTap(widget.onExit),
                    color: P.gray,
                    filled: false,
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // ───── Nour Eldin ─────
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
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
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required bool filled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: filled ? color.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.white,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}