import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MarioGameApp());
  });
}

class Enemy {
  double x, y, width, height, minX, maxX, vx;
  bool active;
  Enemy({required this.x, required this.y, this.width = 30, this.height = 30, required this.minX, required this.maxX, this.vx = -2.0, this.active = true});
  Enemy copy() => Enemy(x: x, y: y, width: width, height: height, minX: minX, maxX: maxX, vx: vx, active: active);
}

class MarioGameApp extends StatelessWidget {
  const MarioGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESCAPE KCET',
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _bgPlayer = AudioPlayer();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _audioInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _startAudio() async {
    if (!_audioInitialized) {
      setState(() => _audioInitialized = true);
      await _bgPlayer.play(AssetSource('soundEffects/home_page.mp3'));
    }
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Floating Background Elements
                ...List.generate(15, (i) => Positioned(
                  left: (i * 137 + 50) % MediaQuery.of(context).size.width,
                  top: (i * 257 + 100) % MediaQuery.of(context).size.height,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (i % 2 == 0 ? 1 : -1) * _controller.value),
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            [Icons.school, Icons.menu_book, Icons.calculate, Icons.edit, Icons.auto_stories][i % 5],
                            size: 40 + (i % 3) * 20,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                )),
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stylized Title
                        Stack(
                          children: [
                            Text(
                              'ESCAPE KCET',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 84,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 12,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.blueAccent.withOpacity(0.3),
                              ),
                            ),
                            Text( // Removed const
                              'ESCAPE KCET',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 84,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 12,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.blueAccent, blurRadius: 20),
                                  Shadow(color: Colors.cyanAccent, blurRadius: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            'THE ACADEMIC ADVENTURE',
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        // Enhanced Play Button
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: () {
                              _bgPlayer.stop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
                              );
                            },
                            child: Container(
                              width: 220,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(45),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                    blurRadius: 60,
                                    spreadRadius: -10,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.orangeAccent, Colors.deepOrange],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                                          const SizedBox(width: 5),
                                          const Text(
                                            'PLAY',
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_audioInitialized)
            GestureDetector(
              onTap: _startAudio,
              child: Container(
                color: Colors.black.withOpacity(0.01), // Almost invisible overlay
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.music_note_rounded, color: Colors.blueAccent, size: 60),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "READY TO ESCAPE?",
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tap anywhere to begin audio",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum CharacterType { red, green, purple }

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> with SingleTickerProviderStateMixin {
  CharacterType selectedCharacter = CharacterType.red;
  late AnimationController _animController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  final AudioPlayer _selectionPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
    
    _glowAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _selectionPlayer.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Text(
                            'ESCAPE KCET',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 76,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.blueAccent.withOpacity(0.8),
                                  offset: const Offset(4, 6),
                                  blurRadius: (_glowAnimation.value * 2).clamp(0.0, 50.0),
                                ),
                                Shadow(
                                  color: Colors.purpleAccent.withOpacity(0.8),
                                  offset: const Offset(-2, -2),
                                  blurRadius: _glowAnimation.value.clamp(0.0, 50.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white30, width: 1.5),
                          ),
                          child: const Text(
                            'SELECT YOUR CHARACTER',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                          ),
                        ),
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildCharacterCard(CharacterType.red, Colors.red, Colors.blue[900]!, 'assets/images/char1.png'),
                                  const SizedBox(width: 25),
                                  _buildCharacterCard(CharacterType.green, Colors.green, Colors.blue[900]!, 'assets/images/char2.png'),
                                  const SizedBox(width: 25),
                                  _buildCharacterCard(CharacterType.purple, Colors.purple, Colors.black, 'assets/images/char3.png'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 45),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    LoadingScreen(characterType: selectedCharacter),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orangeAccent, Colors.deepOrange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 15.0,
                                  spreadRadius: 2.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'START ESCAPE',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCharacterCard(CharacterType type, Color mainColor, Color hatColor, String assetPath) {
    bool isSelected = selectedCharacter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCharacter = type;
        });
        String soundFile = '';
        if (type == CharacterType.red) soundFile = 'char1_sound.mp3';
        else if (type == CharacterType.green) soundFile = 'char2_sound.mp3';
        else if (type == CharacterType.purple) soundFile = 'char3_sound.mp3';
        
        _selectionPlayer.play(AssetSource('soundEffects/$soundFile'));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: isSelected ? 180 : 140,
        height: isSelected ? 220 : 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
              ? [Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.1)] 
              : [Colors.black45, Colors.black26],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.yellowAccent : Colors.white24,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: Colors.yellowAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 3),
                  BoxShadow(color: mainColor.withOpacity(0.4), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 4)),
                ]
              : [const BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: SizedBox(
              width: 110,
              height: 110,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(height: 16, color: hatColor),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(width: 14, height: 14, color: Colors.blue),
                            Container(width: 14, height: 14, color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final grainPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1.0;
      
    // Draw horizontal planks
    for (double y = 0; y < size.height; y += 15) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grainPaint);
    }
    
    // Draw wood grain details
    final detailPaint = Paint()..color = Colors.brown[900]!.withOpacity(0.2);
    for(int i=0; i<15; i++) {
       double dx = (i * 47) % size.width;
       double dy = (i * 23) % size.height;
       canvas.drawOval(Rect.fromLTWH(dx, dy, 20, 4), detailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoadingScreen extends StatefulWidget {
  final CharacterType characterType;
  const LoadingScreen({super.key, required this.characterType});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GameScreen(characterType: widget.characterType),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String charAssetPath;
    Color glowColor;
    switch (widget.characterType) {
      case CharacterType.red:
        charAssetPath = 'assets/images/char1.png';
        glowColor = Colors.redAccent;
        break;
      case CharacterType.green:
        charAssetPath = 'assets/images/char2.png';
        glowColor = Colors.greenAccent;
        break;
      case CharacterType.purple:
        charAssetPath = 'assets/images/char3.png';
        glowColor = Colors.purpleAccent;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity((0.5 * _fadeAnimation.value).clamp(0.0, 1.0)),
                        blurRadius: (40 * _scaleAnimation.value).clamp(0.0, 100.0),
                        spreadRadius: (10 * _scaleAnimation.value).clamp(0.0, 100.0),
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Image.asset(
                      charAssetPath,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, size: 100, color: glowColor),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
                const SizedBox(height: 40),
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    'SIMULATION INITIALIZING...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'Courier',
                      shadows: [
                        Shadow(
                          color: glowColor,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final CharacterType characterType;
  const GameScreen({super.key, required this.characterType});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Ticker _gameTicker;
  late AnimationController _effectController;
  final AudioPlayer _coinPlayer = AudioPlayer();
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final AudioPlayer _diePlayer = AudioPlayer();

  double playerX = 50;
  double playerY = 250;
  double playerVx = 0;
  double playerVy = 0;
  final double playerWidth = 40;
  final double playerHeight = 60;
  final double visualScale = 120;
  final double gravity = 0.5;
  final double jumpForce = -10.0;
  final double moveSpeed = 6.5;

  bool gameWon = false;
  bool isDead = false;
  bool isWinning = false;

  final List<Rect> platforms = [
    const Rect.fromLTWH(0, 350, 600, 300),
    const Rect.fromLTWH(700, 350, 400, 300),
    const Rect.fromLTWH(1200, 350, 800, 300),
    const Rect.fromLTWH(2100, 350, 1000, 300),
    const Rect.fromLTWH(3200, 350, 800, 300),
    const Rect.fromLTWH(300, 280, 150, 20),
    const Rect.fromLTWH(500, 230, 120, 20),
    const Rect.fromLTWH(900, 300, 50, 300),
    const Rect.fromLTWH(950, 260, 50, 300),
    const Rect.fromLTWH(1000, 220, 50, 300),
    const Rect.fromLTWH(1350, 280, 100, 20),
    const Rect.fromLTWH(1500, 240, 120, 20),
    const Rect.fromLTWH(1700, 260, 150, 20),
    const Rect.fromLTWH(2400, 310, 50, 300),
    const Rect.fromLTWH(2450, 270, 50, 300),
    const Rect.fromLTWH(2500, 230, 50, 300),
    const Rect.fromLTWH(2550, 190, 50, 300),
    const Rect.fromLTWH(2600, 150, 50, 300),
    const Rect.fromLTWH(2750, 150, 150, 20),
  ];

  final Rect goal = const Rect.fromLTWH(3600, 100, 20, 250);

  final List<Rect> lava = [
    const Rect.fromLTWH(600, 380, 100, 20),
    const Rect.fromLTWH(1100, 380, 100, 20),
    const Rect.fromLTWH(2000, 380, 100, 20),
    const Rect.fromLTWH(3100, 380, 100, 20),
  ];

  List<Rect> coins = [];
  final List<Rect> initialCoins = [
    const Rect.fromLTWH(150, 310, 20, 20),
    const Rect.fromLTWH(250, 280, 20, 20),
    const Rect.fromLTWH(350, 230, 20, 20),
    const Rect.fromLTWH(550, 160, 20, 20),
    const Rect.fromLTWH(800, 310, 20, 20),
    const Rect.fromLTWH(1050, 260, 20, 20),
    const Rect.fromLTWH(1250, 310, 20, 20),
    const Rect.fromLTWH(1400, 230, 20, 20),
    const Rect.fromLTWH(1550, 170, 20, 20),
    const Rect.fromLTWH(1750, 190, 20, 20),
    const Rect.fromLTWH(2200, 310, 20, 20),
    const Rect.fromLTWH(2650, 100, 20, 20),
    const Rect.fromLTWH(3000, 310, 20, 20),
    const Rect.fromLTWH(3350, 310, 20, 20),
  ];
  int score = 0;

  List<Enemy> enemies = [];
  final List<Enemy> initialEnemies = [
    Enemy(x: 400, y: 320, minX: 100, maxX: 600),
    Enemy(x: 800, y: 320, minX: 700, maxX: 900),
    Enemy(x: 1600, y: 320, minX: 1200, maxX: 2000),
    Enemy(x: 2250, y: 320, minX: 2100, maxX: 2400),
    Enemy(x: 2850, y: 320, minX: 2650, maxX: 3100),
    Enemy(x: 3400, y: 320, minX: 3200, maxX: 3550),
  ];

  bool leftPressed = false;
  bool rightPressed = false;

  @override
  void initState() {
    super.initState();
    _effectController = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    
    _gameTicker = createTicker((elapsed) {
      if (mounted) update();
    });
    _gameTicker.start();
    startGame();
  }

  void startGame() {
    setState(() {
      playerX = 50;
      playerY = 200;
      playerVx = 0;
      playerVy = 0;
      gameWon = false;
      isDead = false;
      isWinning = false;
      leftPressed = false;
      rightPressed = false;
      score = 0;
      enemies = initialEnemies.map((e) => e.copy()).toList();
      coins = initialCoins.map((c) => c).toList(); // Reset coins
    });
  }

  void update() {
    if (gameWon || isDead || !mounted) return;

    setState(() {
      if (isWinning) {
        playerVx = 0;
        if (playerY < 350 - playerHeight) {
          playerY += 4;
        } else {
          playerY = 350 - playerHeight;
          playerX += 2;
        }

        if (playerX >= goal.left + 120) {
          win();
          isWinning = false;
        }
        return;
      }

      if (leftPressed && !rightPressed) {
        playerVx = -moveSpeed;
      } else if (rightPressed && !leftPressed) {
        playerVx = moveSpeed;
      } else {
        playerVx = 0;
      }

      playerX += playerVx;

      Rect playerRectH = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);
      for (var platform in platforms) {
        if (playerRectH.overlaps(platform)) {
          if (playerVx > 0) {
            playerX = platform.left - playerWidth;
          } else if (playerVx < 0) {
            playerX = platform.right;
          }
          playerVx = 0;
        }
      }

      if (playerX < 0) playerX = 0;
      if (playerX > goal.left + 150) playerX = goal.left + 150;

      playerVy += gravity;
      playerY += playerVy;

      Rect playerRectV = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);
      for (var platform in platforms) {
        if (playerRectV.overlaps(platform)) {
          if (playerVy > 0) {
            playerY = platform.top - playerHeight;
            playerVy = 0;
          } else if (playerVy < 0) {
            playerY = platform.bottom;
            playerVy = 0;
          }
        }
      }

      Rect playerFinalRect = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);

      for (int i = coins.length - 1; i >= 0; i--) {
        if (playerFinalRect.overlaps(coins[i])) {
          coins.removeAt(i);
          score += 10;
          _coinPlayer.play(AssetSource('soundEffects/mario_coin_sound.mp3'));
        }
      }

      for (var enemy in enemies) {
        enemy.x += enemy.vx;
        bool platformHit = false;
        Rect enemyRect = Rect.fromLTWH(enemy.x, enemy.y, enemy.width, enemy.height);
        for (var platform in platforms) {
          if (enemyRect.overlaps(platform)) {
            platformHit = true;
            break;
          }
        }

        if (platformHit) {
          enemy.x -= enemy.vx;
          enemy.vx = -enemy.vx;
        } else if (enemy.x <= enemy.minX) {
          enemy.x = enemy.minX;
          enemy.vx = enemy.vx.abs();
        } else if (enemy.x + enemy.width >= enemy.maxX) {
          enemy.x = enemy.maxX - enemy.width;
          enemy.vx = -enemy.vx.abs();
        }
        
        if (playerFinalRect.overlaps(enemyRect)) {
          if (playerVy > 0 && playerFinalRect.bottom < enemyRect.top + 15) {
            enemy.active = false;
            playerVy = -8.0;
            score += 20;
          } else {
            die();
          }
        }
      }
      enemies.removeWhere((e) => !e.active);

      if (playerY > 600) die();
      for (var l in lava) {
        if (playerFinalRect.overlaps(l)) die();
      }
      if (playerFinalRect.overlaps(goal)) isWinning = true;
    });
  }

  void jump() {
    if (isWinning || gameWon || isDead) return;
    bool onGround = false;
    Rect jumpCheck = Rect.fromLTWH(playerX, playerY + 1, playerWidth, playerHeight);
    for (var platform in platforms) {
      if (jumpCheck.overlaps(platform)) {
        onGround = true;
        break;
      }
    }
    if (onGround) {
      playerVy = jumpForce;
      _jumpPlayer.play(AssetSource('soundEffects/mario_jump.mp3'));
    }
  }

  void die() {
    if (!isDead) {
      _diePlayer.play(AssetSource('soundEffects/mario_dies.mp3'));
      setState(() => isDead = true);
    }
  }
  
  void win() => setState(() => gameWon = true);

  @override
  void dispose() {
    _gameTicker.dispose();
    _effectController.dispose();
    _coinPlayer.dispose();
    _jumpPlayer.dispose();
    _diePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cameraX = playerX - screenWidth / 2 + playerWidth / 2;
    if (cameraX < 0) cameraX = 0;

    Color charMainColor;
    String charAssetPath;
    switch (widget.characterType) {
      case CharacterType.red:
        charMainColor = Colors.red;
        charAssetPath = 'assets/images/char1.png';
        break;
      case CharacterType.green:
        charMainColor = Colors.green;
        charAssetPath = 'assets/images/char2.png';
        break;
      case CharacterType.purple:
        charMainColor = Colors.purple;
        charAssetPath = 'assets/images/char3.png';
        break;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8E4D9), Color(0xFFF5F2E8)], // Warm classroom wall colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Focus(
          autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) leftPressed = true;
                else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) rightPressed = true;
                else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) jump();
              } else if (event is KeyUpEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) leftPressed = false;
                else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) rightPressed = false;
              }
              return KeyEventResult.handled;
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                    // Layer 1: Classroom Windows and Wall Posters (Distant)
                    RepaintBoundary(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ...List.generate(8, (i) => Positioned(
                            left: (i * 600) - (cameraX * 0.1),
                            top: 100,
                            child: Opacity(
                              opacity: 0.25, // Increased from 0.1
                              child: Icon(
                                i % 2 == 0 ? Icons.window : Icons.analytics, 
                                size: 400, 
                                color: Colors.blueGrey[400] // Slightly darker
                              )
                            ),
                          )),
                        ],
                      ),
                    ),
                    // Layer 2: Classroom Desks, Chairs and Shelves (Middle)
                    RepaintBoundary(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ...List.generate(15, (i) => Positioned(
                            left: (i * 300) - (cameraX * 0.3),
                            bottom: 300,
                            child: Opacity(
                              opacity: 0.5, // Increased from 0.25
                              child: Icon(
                                i % 3 == 0 ? Icons.event_seat : (i % 3 == 1 ? Icons.auto_stories : Icons.table_restaurant), 
                                size: 100, 
                                color: Colors.brown[400] // More solid brown
                              )
                            ),
                          )),
                        ],
                      ),
                    ),
                    // Layer 3: Floating Stationery (Pens, Books, Calculators)
                    RepaintBoundary(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ...List.generate(10, (i) => Positioned(
                            left: (i * 500) - (cameraX * 0.5),
                            top: 80.0 + (i % 3) * 70,
                            child: Opacity(
                              opacity: 0.6, // Increased from 0.2
                              child: Icon(
                                i % 3 == 0 ? Icons.edit : (i % 3 == 1 ? Icons.calculate : Icons.menu_book), 
                                size: 60, 
                                color: i % 2 == 0 ? Colors.blue[400] : Colors.deepOrange[300] // More distinct colors
                              )
                            ),
                          )),
                        ],
                      ),
                    ),
                      ...platforms.where((p) => p.right >= cameraX - 100 && p.left <= cameraX + screenWidth + 100).map((p) => Positioned(
                        left: p.left - cameraX, top: p.top, width: p.width, height: p.height,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.brown[800]!, Colors.brown[600]!], 
                              begin: Alignment.topCenter, 
                              end: Alignment.bottomCenter
                            ),
                            border: Border(top: BorderSide(color: Colors.brown[400]!, width: 4)),
                            boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 6)],
                          ),
                          child: CustomPaint(painter: PlatformTexturePainter()),
                        ),
                      )),
                      ...lava.where((l) => l.right >= cameraX - 100 && l.left <= cameraX + screenWidth + 100).map((l) => Positioned(
                        left: l.left - cameraX, top: l.top, width: l.width, height: l.height,
                        child: AnimatedBuilder(
                          animation: _effectController,
                          builder: (context, _) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.orange[900]!, Colors.red[700]!], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity((0.4 + (0.2 * _effectController.value)).clamp(0.0, 1.0)), 
                                  blurRadius: (10.0 + (5.0 * _effectController.value)).clamp(0.0, 50.0), 
                                  spreadRadius: 2.0
                                )
                              ],
                            ),
                          ),
                        ),
                      )),
                      ...enemies.where((e) => e.x + e.width >= cameraX - 100 && e.x <= cameraX + screenWidth + 100).map((e) => Positioned(
                        left: e.x - cameraX, top: e.y, width: e.width, height: e.height,
                        child: AnimatedBuilder(
                          animation: _effectController,
                          builder: (context, _) => Transform.translate(
                            offset: Offset(0, 3 * _effectController.value),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.deepPurple[900], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent, width: 2), boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 6)]),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Container(width: 6, height: 6, color: Colors.orange), Container(width: 6, height: 6, color: Colors.orange)]), const SizedBox(height: 4), Container(width: 12, height: 2, color: Colors.orange)]),
                            ),
                          ),
                        ),
                      )),
                      ...coins.where((c) => c.right >= cameraX - 100 && c.left <= cameraX + screenWidth + 100).map((c) => Positioned(
                        left: c.left - cameraX, top: c.top, width: c.width, height: c.height,
                        child: AnimatedBuilder(
                          animation: _effectController,
                          builder: (context, _) => Transform.translate(
                            offset: Offset(0, -5 * _effectController.value),
                            child: Container(decoration: BoxDecoration(color: Colors.yellow[600], shape: BoxShape.circle, border: Border.all(color: Colors.orange[800]!, width: 2), boxShadow: [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 8)]), child: const Center(child: Icon(Icons.star, size: 12, color: Colors.white))),
                          ),
                        ),
                      )),
                      if (goal.right >= cameraX - 100 && goal.left <= cameraX + screenWidth + 100) Positioned(
                        left: goal.left - cameraX, top: goal.top, width: goal.width, height: goal.height,
                        child: AnimatedBuilder(
                          animation: _effectController,
                          builder: (context, _) => Stack(clipBehavior: Clip.none, children: [
                            Container(width: 8, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[400]!, Colors.grey[700]!]))),
                            Positioned(left: 0, top: 0, child: Transform.rotate(angle: (0.1 * _effectController.value), child: Container(width: 50, height: 35, decoration: BoxDecoration(color: Colors.green[400], borderRadius: const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)), border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.flag, color: Colors.white, size: 20))))]),
                        ),
                      ),
                      if (goal.right >= cameraX - 250) Positioned(
                        left: goal.left + 50 - cameraX, top: 100, width: 250, height: 250,
                        child: Image.asset(
                          'assets/images/fort.jpg',
                          fit: BoxFit.contain, // Using contain to ensure whole image is seen
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 250, height: 250,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[800],
                              border: Border.all(color: Colors.white24, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.castle, color: Colors.white, size: 80),
                          ),
                        ),
                      ),
                      Positioned(
                        left: playerX - cameraX - ((visualScale - playerWidth) / 2),
                        top: playerY - ((visualScale - playerHeight) / 2),
                        width: visualScale, height: visualScale,
                        child: Hero(tag: 'player', child: Image.asset(charAssetPath, fit: BoxFit.contain, errorBuilder: (c, e, s) => Container(decoration: BoxDecoration(color: charMainColor, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black, width: 2))))),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20, left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white24)),
                    child: Row(children: [const Icon(Icons.stars, color: Colors.yellow, size: 28), const SizedBox(width: 10), Text('$score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2, fontFamily: 'Courier'))]),
                  ),
                ),
                Positioned(
                  bottom: 30, left: 30,
                  child: Row(children: [
                    GestureDetector(onTapDown: (_) => leftPressed = true, onTapUp: (_) => leftPressed = false, onTapCancel: () => leftPressed = false, child: Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, size: 30))),
                    const SizedBox(width: 20),
                    GestureDetector(onTapDown: (_) => rightPressed = true, onTapUp: (_) => rightPressed = false, onTapCancel: () => rightPressed = false, child: Container(width: 65, height: 65, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, size: 30))),
                  ]),
                ),
                Positioned(bottom: 30, right: 30, child: GestureDetector(onTapDown: (_) => jump(), child: Container(width: 75, height: 75, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, size: 40)))),
                if (isDead) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("GAME OVER", style: TextStyle(fontSize: 48, color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), textStyle: const TextStyle(fontSize: 24)), onPressed: startGame, child: const Text("Restart"))])))),
                if (gameWon) Positioned.fill(child: Container(color: Colors.green.withOpacity(0.8), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("You escaped KCET", style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 20), ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), textStyle: const TextStyle(fontSize: 24)), onPressed: startGame, child: const Text("Play Again"))])))),
              ],
            ),
          ),
        ),
      );
    }
}