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

  // Level definition
  final List<Rect> platforms = [
    // Ground level segments
    const Rect.fromLTWH(0, 350, 400, 50),
    const Rect.fromLTWH(450, 350, 300, 50),
    const Rect.fromLTWH(800, 350, 400, 50),
    const Rect.fromLTWH(1300, 350, 600, 50),
    
    // Elevated platforms
    const Rect.fromLTWH(200, 250, 100, 20),
    const Rect.fromLTWH(350, 150, 100, 20),
    
    // Stairs / obstacles
    const Rect.fromLTWH(600, 300, 50, 50),
    const Rect.fromLTWH(650, 250, 50, 100),
    const Rect.fromLTWH(700, 200, 50, 150),
    
    // More platforms before the end
    const Rect.fromLTWH(1000, 250, 100, 20),
    const Rect.fromLTWH(1150, 150, 100, 20),
    
    // Final high platform
    const Rect.fromLTWH(1500, 200, 150, 20),
  ];

  final Rect goal = const Rect.fromLTWH(1750, 270, 40, 80); // End flag
  
  final List<Rect> lava = [
    const Rect.fromLTWH(400, 380, 50, 20),
    const Rect.fromLTWH(750, 380, 50, 20),
    const Rect.fromLTWH(1200, 380, 100, 20),
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
    });
    
    gameLoop?.cancel();
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
    });
  }
  
  void update() {
    if (gameWon || isDead || !mounted) return;

    setState(() {
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
      Rect playerRectH = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);
      for (var platform in platforms) {
        if (playerRectH.overlaps(platform)) {
          if (playerVx > 0) { // Moving right
            playerX = platform.left - playerWidth;
          } else if (playerVx < 0) { // Moving left
            playerX = platform.right;
          }
          playerVx = 0;
        }
      }

      // Block player from going too far left
      if (playerX < 0) {
        playerX = 0;
      }

      // Vertical movement & gravity
      playerVy += gravity;
      playerY += playerVy;
      
      // Vertical collision
      Rect playerRectV = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);
      for (var platform in platforms) {
        if (playerRectV.overlaps(platform)) {
          if (playerVy > 0) { // Falling onto a platform
            playerY = platform.top - playerHeight;
            playerVy = 0;
          } else if (playerVy < 0) { // Jumping into a ceiling
            playerY = platform.bottom;
            playerVy = 0;
          }
        }
      }
      
      // Check hazards
      Rect playerFinalRect = Rect.fromLTWH(playerX, playerY, playerWidth, playerHeight);
      
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
        win();
      }
    });
  }
  
  void jump() {
    // Ground detection: check if there's a platform 1 pixel below the player
    bool onGround = false;
    Rect jumpCheck = Rect.fromLTWH(playerX, playerY + 1, playerWidth, playerHeight);
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
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              leftPressed = true;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              rightPressed = true;
            } else if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
              jump();
            }
          } else if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
              leftPressed = false;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
              rightPressed = false;
            }
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            // Game world container (translations applied for camera)
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(-cameraX, 0),
                child: Stack(
                  children: [
                    // Render Platforms
                    ...platforms.map((platform) => Positioned(
                      left: platform.left,
                      top: platform.top,
                      width: platform.width,
                      height: platform.height,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.brown[600],
                          border: Border(
                            top: BorderSide(color: Colors.green[500]!, width: 6),
                            left: BorderSide(color: Colors.brown[800]!, width: 2),
                            right: BorderSide(color: Colors.brown[800]!, width: 2),
                            bottom: BorderSide(color: Colors.brown[800]!, width: 2),
                          ),
                        ),
                      ),
                    )),
                    
                    // Render Lava
                    ...lava.map((l) => Positioned(
                      left: l.left,
                      top: l.top,
                      width: l.width,
                      height: l.height,
                      child: Container(
                        color: Colors.orange,
                        child: Text(
                          "~~",
                          style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),

                    // Render Goal
                    Positioned(
                      left: goal.left,
                      top: goal.top,
                      width: goal.width,
                      height: goal.height,
                      child: Container(
                        color: Colors.yellowAccent[100],
                        child: const Icon(Icons.flag, size: 40, color: Colors.green),
                      ),
                    ),

                    // Render Player (Mario representation)
                    Positioned(
                      left: playerX,
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
                                Container(width: 8, height: 8, color: Colors.blue),
                                Container(width: 8, height: 8, color: Colors.blue),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                      width: 65, height: 65,
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
                      width: 65, height: 65,
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
                  width: 75, height: 75,
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
                        const Text("GAME OVER", style: TextStyle(fontSize: 48, color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          onPressed: startGame,
                          child: const Text("Restart"),
                        )
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
                        const Text("LEVEL CLEARED!", style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          onPressed: startGame,
                          child: const Text("Play Again"),
                        )
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
