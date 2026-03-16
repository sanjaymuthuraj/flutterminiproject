import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MarioGameApp());
}

class MarioGameApp extends StatelessWidget {
  const MarioGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock orientation to landscape for the ideal game experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Mario',
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game loop timer
  Timer? gameLoop;

  // Game state
  double playerX = 50;
  double playerY = 300;
  double playerVx = 0;
  double playerVy = 0;
  final double playerWidth = 30;
  final double playerHeight = 30;

  // Constants
  final double gravity = 0.5; // per frame
  final double jumpForce = -10.0;
  final double moveSpeed = 4.0;

  // Game won/lost
  bool gameWon = false;
  bool isDead = false;
  bool isWinning = false;

  // Level definition
  final List<Rect> platforms = [
    // Ground level segments (extended height so it acts as solid ground)
    const Rect.fromLTWH(0, 350, 600, 300),
    const Rect.fromLTWH(700, 350, 400, 300),
    const Rect.fromLTWH(1200, 350, 800, 300),
    const Rect.fromLTWH(2100, 350, 1000, 300),
    const Rect.fromLTWH(3200, 350, 800, 300),

    // Elevated platforms
    const Rect.fromLTWH(300, 280, 150, 20),
    const Rect.fromLTWH(500, 210, 120, 20), // Lowered and widened

    // Stairs / obstacles
    const Rect.fromLTWH(900, 300, 50, 300),
    const Rect.fromLTWH(950, 260, 50, 300),
    const Rect.fromLTWH(1000, 220, 50, 300),

    // Large gap and small floating platforms
    const Rect.fromLTWH(1350, 280, 100, 20),
    const Rect.fromLTWH(1500, 220, 120, 20), // Lowered and brought closer
    const Rect.fromLTWH(1700, 240, 150, 20), // Brought closer

    // Final high stair climb
    const Rect.fromLTWH(2400, 310, 50, 300),
    const Rect.fromLTWH(2450, 270, 50, 300),
    const Rect.fromLTWH(2500, 230, 50, 300),
    const Rect.fromLTWH(2550, 190, 50, 300),
    const Rect.fromLTWH(2600, 150, 50, 300),

    // Final high platform before pole
    const Rect.fromLTWH(2750, 150, 150, 20),
  ];

  final Rect goal = const Rect.fromLTWH(3600, 100, 20, 250); // End flag pole

  final List<Rect> lava = [
    const Rect.fromLTWH(600, 380, 100, 20),
    const Rect.fromLTWH(1100, 380, 100, 20),
    const Rect.fromLTWH(2000, 380, 100, 20),
    const Rect.fromLTWH(3100, 380, 100, 20),
  ];

  // Input state
  bool leftPressed = false;
  bool rightPressed = false;

  @override
  void initState() {
    super.initState();
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
    });

    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
    });
  }

  void update() {
    if (gameWon || isDead || !mounted) return;

    setState(() {
      if (isWinning) {
        playerVx = 0;
        if (playerY < 350 - playerHeight) {
          playerY += 4; // Slide down pole
        } else {
          playerY = 350 - playerHeight;
          playerX += 2; // Walk into castle
        }

        if (playerX >= goal.left + 85) {
          // Mario enters castle door
          win();
          isWinning = false;
        }
        return;
      }

      // Horizontal movement
      if (leftPressed && !rightPressed) {
        playerVx = -moveSpeed;
      } else if (rightPressed && !leftPressed) {
        playerVx = moveSpeed;
      } else {
        playerVx = 0;
      }

      // Apply horizontal movement
      playerX += playerVx;

      // Horizontal collision
      Rect playerRectH = Rect.fromLTWH(
        playerX,
        playerY,
        playerWidth,
        playerHeight,
      );
      for (var platform in platforms) {
        if (playerRectH.overlaps(platform)) {
          if (playerVx > 0) {
            // Moving right
            playerX = platform.left - playerWidth;
          } else if (playerVx < 0) {
            // Moving left
            playerX = platform.right;
          }
          playerVx = 0;
        }
      }

      // Block player from going too far left or right
      if (playerX < 0) {
        playerX = 0;
      } else if (playerX > goal.left + 150) {
        playerX = goal.left + 150;
      }

      // Vertical movement & gravity
      playerVy += gravity;
      playerY += playerVy;

      // Vertical collision
      Rect playerRectV = Rect.fromLTWH(
        playerX,
        playerY,
        playerWidth,
        playerHeight,
      );
      for (var platform in platforms) {
        if (playerRectV.overlaps(platform)) {
          if (playerVy > 0) {
            // Falling onto a platform
            playerY = platform.top - playerHeight;
            playerVy = 0;
          } else if (playerVy < 0) {
            // Jumping into a ceiling
            playerY = platform.bottom;
            playerVy = 0;
          }
        }
      }

      // Check hazards
      Rect playerFinalRect = Rect.fromLTWH(
        playerX,
        playerY,
        playerWidth,
        playerHeight,
      );

      // Death by falling below screen
      if (playerY > 600) {
        die();
      }

      // Death by lava
      for (var l in lava) {
        if (playerFinalRect.overlaps(l)) {
          die();
        }
      }

      // Win condition (hitting the goal)
      if (playerFinalRect.overlaps(goal)) {
        isWinning = true;
      }
    });
  }

  void jump() {
    if (isWinning || gameWon || isDead) return;
    // Ground detection: check if there's a platform 1 pixel below the player
    bool onGround = false;
    Rect jumpCheck = Rect.fromLTWH(
      playerX,
      playerY + 1,
      playerWidth,
      playerHeight,
    );
    for (var platform in platforms) {
      if (jumpCheck.overlaps(platform)) {
        onGround = true;
        break;
      }
    }

    // Apply jump velocity if on the ground
    if (onGround) {
      playerVy = jumpForce;
    }
  }

  void die() {
    isDead = true;
  }

  void win() {
    gameWon = true;
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen width to center camera on the player
    double screenWidth = MediaQuery.of(context).size.width;
    double cameraX = playerX - screenWidth / 2 + playerWidth / 2;

    // Clamp the camera so it doesn't show past the start of the level
    if (cameraX < 0) cameraX = 0;

    return Scaffold(
      backgroundColor: Colors.lightBlue[300], // Sky color
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.keyA) {
              leftPressed = true;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.keyD) {
              rightPressed = true;
            } else if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.arrowUp ||
                event.logicalKey == LogicalKeyboardKey.keyW) {
              jump();
            }
          } else if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
                event.logicalKey == LogicalKeyboardKey.keyA) {
              leftPressed = false;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.keyD) {
              rightPressed = false;
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            
            Positioned.fill(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Render Platforms
                  ...platforms
                      .where((platform) {
                        
                        return platform.right >= cameraX - 100 &&
                            platform.left <= cameraX + screenWidth + 100;
                      })
                      .map(
                        (platform) => Positioned(
                          left: platform.left - cameraX,
                          top: platform.top,
                          width: platform.width,
                          height: platform.height,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.brown[600],
                              border: Border(
                                top: BorderSide(
                                  color: Colors.green[500]!,
                                  width: 6,
                                ),
                                left: BorderSide(
                                  color: Colors.brown[800]!,
                                  width: 2,
                                ),
                                right: BorderSide(
                                  color: Colors.brown[800]!,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                  // Render Lava
                  ...lava
                      .where((l) {
                        return l.right >= cameraX - 100 &&
                            l.left <= cameraX + screenWidth + 100;
                      })
                      .map(
                        (l) => Positioned(
                          left: l.left - cameraX,
                          top: l.top,
                          width: l.width,
                          height: l.height,
                          child: Container(
                            color: Colors.orange,
                            child: Text(
                              "~~",
                              style: TextStyle(
                                color: Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                  // Render Goal (only if visible)
                  if (goal.right >= cameraX - 100 &&
                      goal.left <= cameraX + screenWidth + 100)
                    Positioned(
                      left: goal.left - cameraX,
                      top: goal.top,
                      width: goal.width,
                      height: goal.height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(color: Colors.grey[300]), // Pole
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 40,
                              height: 30,
                              color: Colors.green,
                            ), // Flag
                          ),
                        ],
                      ),
                    ),

                  // Render Castle (only if visible)
                  if (goal.right >= cameraX - 100)
                    Positioned(
                      left: goal.left + 70 - cameraX,
                      top: 150,
                      width: 90,
                      height: 200,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange[300],
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 30,
                            width: 30,
                            height: 50,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Render Player (Mario representation)
                  Positioned(
                    left: playerX - cameraX,
                    top: playerY,
                    width: playerWidth,
                    height: playerHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.red[900]!, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 6,
                            color: Colors.blue[900], // "Hat" or topmost detail
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                color: Colors.blue,
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // On-Screen Controls (Left/Right)
            Positioned(
              bottom: 30,
              left: 30,
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (_) => leftPressed = true,
                    onTapUp: (_) => leftPressed = false,
                    onTapCancel: () => leftPressed = false,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 30),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTapDown: (_) => rightPressed = true,
                    onTapUp: (_) => rightPressed = false,
                    onTapCancel: () => rightPressed = false,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward, size: 30),
                    ),
                  ),
                ],
              ),
            ),

            // On-Screen Control (Jump)
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTapDown: (_) => jump(),
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, size: 40),
                ),
              ),
            ),

            // Defeat Overlay
            if (isDead)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "GAME OVER",
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          onPressed: startGame,
                          child: const Text("Restart"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Victory Overlay
            if (gameWon)
              Positioned.fill(
                child: Container(
                  color: Colors.green.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "LEVEL CLEARED!",
                          style: TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          onPressed: startGame,
                          child: const Text("Play Again"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
