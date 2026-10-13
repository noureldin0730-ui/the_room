import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/save_manager.dart';
import 'game_over_screen.dart';

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

class RoomScreen extends StatefulWidget {
  final int roomId;
  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  int _attempts = 3;
  double _light = 1.0;         // الكشاف
  bool _showHint = false;
  String _hintText = '';
  int _selectedStep = 0;
  List<int> _playerOrder = [];
  int _wrongAnswer = 0;
  Timer? _lightTimer;
  Timer? _shadowTimer;
  Offset _shadowPos = Offset(0, 0);
  bool _shadowVisible = false;

  // بيانات الغرف
  late RoomData _room;

  @override
  void initState() {
    super.initState();
    _room = _getRoomData(widget.roomId);
    _startLightTimer();
    _startShadowTimer();
  }

  @override
  void dispose() {
    _lightTimer?.cancel();
    _shadowTimer?.cancel();
    super.dispose();
  }

  // ═══ الكشاف — بيضعف مع كل غلطة ═══
  void _startLightTimer() {
    _lightTimer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) return;
      setState(() {
        _light -= 0.005;
      });
      if (_light <= 0) {
        t.cancel();
        _triggerGameOver('الكشاف خلص... الظلمة خدتك');
      }
    });
  }

  // ═══ الظل — بيمر كل شوية ═══
  void _startShadowTimer() {
    _shadowTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted) return;
      final rng = Random();
      setState(() {
        _shadowPos = Offset(
          rng.nextDouble() * 200 - 100,
          rng.nextDouble() * 100 - 50,
        );
        _shadowVisible = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _shadowVisible = false);
      });
    });
  }

  void _wrongAttempt() {
    HapticFeedback.heavyImpact();
    setState(() {
      _attempts--;
      _light -= 0.15;
      _wrongAnswer++;
    });
    if (_attempts <= 0 || _light <= 0) {
      _triggerGameOver(_room.failReason);
    }
  }

  void _triggerGameOver(String reason) {
    _lightTimer?.cancel();
    _shadowTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameOverScreen(
          roomId: widget.roomId,
          reason: reason,
          onRetry: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => RoomScreen(roomId: widget.roomId),
              ),
            );
          },
          onRestart: () {
            SaveManager.clearAll();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const RoomScreen(roomId: 1),
              ),
            );
          },
          onExit: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  void _onCorrect() {
    HapticFeedback.mediumImpact();
    SaveManager.setCurrentRoom(widget.roomId + 1);
    setState(() {
      _hintText = 'اللغز اتحل. الباب اتفتح.';
      _showHint = true;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RoomScreen(roomId: widget.roomId + 1),
        ),
      );
    });
  }

  // ═══ بيانات الغرفة ═══
  RoomData _getRoomData(int id) {
    // دور على الغرفة
    if (id > 5) {
      return RoomData(
        title: 'النهاية',
        description: 'خرجت... لكن مش لوحدك.',
        failReason: 'الظلمة خدتك في النهاية',
      );
    }
    return _rooms[id - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.black,
      body: Stack(
        children: [
          // ───── الظل (خلف كل حاجة) ─────
          if (_shadowVisible)
            Positioned(
              left: MediaQuery.of(context).size.width / 2 + _shadowPos.dx,
              top: MediaQuery.of(context).size.height / 2 + _shadowPos.dy,
              child: Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      P.gray.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),

          // ───── الغرفة ─────
          SafeArea(
            child: Column(
              children: [
                // الشريط العلوي
                _buildTopBar(),
                Expanded(
                  child: Center(
                    child: _buildRoomContent(),
                  ),
                ),
              ],
            ),
          ),

          // ───── الكشاف (فوق كل حاجة) ─────
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _light,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    P.black.withOpacity(0.85),
                    P.black,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Icon(Icons.arrow_back, color: P.gray, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'الغرفة ${widget.roomId}',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.rare,
              fontSize: 13,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // مؤشر الكشاف
          Row(
            children: [
              const Icon(Icons.lightbulb, color: P.gold, size: 16),
              const SizedBox(width: 6),
              Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: P.line,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _light.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _light > 0.5
                          ? P.gold
                          : (_light > 0.2 ? P.rare : P.blood),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // المحاولات
          Row(
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  i < _attempts ? Icons.favorite : Icons.favorite_border,
                  color: i < _attempts ? P.blood : P.gray,
                  size: 14,
                ),
              );
            }),
          ),
          const SizedBox(width: 20),
          const Text(
            'Nour Eldin',
            style: TextStyle(
              color: P.gray,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomContent() {
    // الغرفة حسب الـ id
    switch (widget.roomId) {
      case 1:
        return _buildRoom1();
      case 2:
        return _buildRoom2();
      case 3:
        return _buildRoom3();
      case 4:
        return _buildRoom4();
      case 5:
        return _buildRoom5();
      default:
        return _buildFinalRoom();
    }
  }

  // ═══ الغرفة 1: ترتيب الرموز ═══
  Widget _buildRoom1() {
    final correctOrder = [2, 4, 1, 3];
    return _buildOrderPuzzle(
      title: '4 رموز على الحيطة',
      hint: 'اضغط عليهم بالترتيب الصح',
      symbols: ['●', '■', '▲', '◆'],
      correctOrder: correctOrder,
      playerOrder: _playerOrder,
      onSymbolTap: (index) {
        setState(() {
          _playerOrder.add(index);
          if (_playerOrder.length == correctOrder.length) {
            final correct = _playerOrder.toString() == correctOrder.toString();
            if (correct) {
              _onCorrect();
            } else {
              _playerOrder = [];
              _wrongAttempt();
            }
          }
        });
      },
    );
  }

  // ═══ الغرفة 2: كود ═══
  Widget _buildRoom2() {
    return _buildCodePuzzle(
      title: 'كود على الباب',
      hint: 'الأرقام ظاهرة على الحيطة: 7  3  9',
      correctCode: '739',
    );
  }

  // ═══ الغرفة 3: مطابقة ═══
  Widget _buildRoom3() {
    return _buildMatchPuzzle();
  }

  // ═══ الغرفة 4: تسلسل ═══
  Widget _buildRoom4() {
    final correctOrder = [4, 2, 3, 1];
    return _buildOrderPuzzle(
      title: '4 رموز بلون أحمر',
      hint: 'الترتيب حسب الحجم',
      symbols: ['★', '☆', '♠', '♣'],
      correctOrder: correctOrder,
      playerOrder: _playerOrder,
      onSymbolTap: (index) {
        setState(() {
          _playerOrder.add(index);
          if (_playerOrder.length == correctOrder.length) {
            final correct = _playerOrder.toString() == correctOrder.toString();
            if (correct) {
              _onCorrect();
            } else {
              _playerOrder = [];
              _wrongAttempt();
            }
          }
        });
      },
    );
  }

  // ═══ الغرفة 5: الباب الأخير ═══
  Widget _buildRoom5() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'الباب الأخير',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.rare,
              fontSize: 32,
              letterSpacing: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'وراه... حاجة.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.gray,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _onCorrect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: P.blood, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: P.blood.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'افتح الباب',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: P.white,
                  fontSize: 20,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ النهاية ═══
  Widget _buildFinalRoom() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'خرجت.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.white,
              fontSize: 48,
              letterSpacing: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'بس... إنت مش لوحدك.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.gray,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: P.rare, width: 2),
              ),
              child: const Text(
                'من الأول',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: P.white,
                  fontSize: 16,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ Widgets مساعدة ═══

  Widget _buildOrderPuzzle({
    required String title,
    required String hint,
    required List<String> symbols,
    required List<int> correctOrder,
    required List<int> playerOrder,
    required void Function(int) onSymbolTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: P.rare,
            fontSize: 20,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: P.gray,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(symbols.length, (i) {
            final selected = playerOrder.contains(i);
            return GestureDetector(
              onTap: () => onSymbolTap(i + 1),
              child: Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? P.rare : P.gray,
                    width: selected ? 3 : 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: P.rare.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  symbols[i],
                  style: TextStyle(
                    color: selected ? P.rare : P.white,
                    fontSize: 32,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Text(
          'اخترت: ${playerOrder.join(" → ")}',
          style: const TextStyle(color: P.gray, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCodePuzzle({
    required String title,
    required String hint,
    required String correctCode,
  }) {
    String input = '';
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.rare,
                fontSize: 20,
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: P.gray, fontSize: 12),
            ),
            const SizedBox(height: 30),
            // شاشة الكود
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: P.rare, width: 2),
              ),
              child: Text(
                input.isEmpty ? '_ _ _' : input.split('').join(' '),
                style: const TextStyle(
                  color: P.white,
                  fontSize: 40,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // أزرار الأرقام
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(10, (i) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (input.length < 3) {
                      setLocalState(() => input += i.toString());
                      if (input.length == 3) {
                        if (input == correctCode) {
                          _onCorrect();
                        } else {
                          input = '';
                          setLocalState(() {});
                          _wrongAttempt();
                        }
                      }
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: P.gray),
                    ),
                    child: Text(
                      '$i',
                      style: const TextStyle(
                        color: P.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchPuzzle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '3 مرايا',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.rare,
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'فيه مراية واحدة فيها الانعكاس الصح',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: P.gray, fontSize: 12),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              final isCorrect = i == 1;
              return GestureDetector(
                onTap: () {
                  if (isCorrect) {
                    _onCorrect();
                  } else {
                    _wrongAttempt();
                  }
                },
                child: Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: P.rare, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      isCorrect ? 'أنت' : 'مش أنت',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: isCorrect ? P.white : P.gray,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══ Room Data ═══
class RoomData {
  final String title;
  final String description;
  final String failReason;
  const RoomData({
    required this.title,
    required this.description,
    required this.failReason,
  });
}

final List<RoomData> _rooms = [
  const RoomData(
    title: 'الغرفة 1',
    description: '4 رموز على الحيطة',
    failReason: 'الظلمة خدتك... الألغاز صعبة',
  ),
  const RoomData(
    title: 'الغرفة 2',
    description: 'كود على الباب',
    failReason: 'الكود غلط 3 مرات. الظلمة خدتك.',
  ),
  const RoomData(
    title: 'الغرفة 3',
    description: '3 مرايا',
    failReason: 'اخترت المراية الغلط. الظلمة خدتك.',
  ),
  const RoomData(
    title: 'الغرفة 4',
    description: '4 رموز حمراء',
    failReason: 'الترتيب غلط. الظلمة خدتك.',
  ),
  const RoomData(
    title: 'الغرفة 5',
    description: 'الباب الأخير',
    failReason: 'الباب ما اتفتحش. الظلمة خدتك.',
  ),
];