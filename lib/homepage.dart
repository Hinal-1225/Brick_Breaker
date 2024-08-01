import 'dart:async';

import 'package:brick_breaker/ball.dart';
import 'package:brick_breaker/brick.dart';
import 'package:brick_breaker/gameoverscreen.dart';
import 'package:brick_breaker/player.dart';
import 'package:flutter/material.dart';
import 'package:brick_breaker/coverscreen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomepageState extends State<Homepage> {
  ///ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXIncrements = 0.02;
  double ballYIncrements = 0.01;
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  ///player variables
  double playerX = -0.2;
  double playerWidth = 0.4; //out of 2

  ///brick variables
  static double firstBrickX = -1 + wallGap;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.4; //out of 2
  static double brickHeight = 0.05; //out of 2
  static double brickGap = 0.01;
  static int numberOfBricksInRow = 3;
  static double wallGap = 0.5 *
      (2 -
          numberOfBricksInRow * brickWidth -
          (numberOfBricksInRow - 1) * brickGap);

  List myBricks = [
    ///[x, y, broken]
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
  ];

  ///game setting
  bool hasGameStarted = false;
  bool isGameOver = false;

  ///start game
  void startGame() {
    hasGameStarted = true;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      ///update direction
      updateDirection();

      ///move ball
      moveBall();

      ///check if player dead
      if (isPlayerDead()) {
        timer.cancel();
        isGameOver = true;
      }

      ///check if brick is hit
      checkForBrokenBricks();
    });
  }

  ///move ball
  void moveBall() {
    setState(() {
      ///move horizontally
      if (ballXDirection == direction.LEFT) {
        ballX -= ballXIncrements;
      } else if (ballXDirection == direction.RIGHT) {
        ballX += ballXIncrements;
      }

      ///move vertically
      if (ballYDirection == direction.DOWN) {
        ballY += ballYIncrements;
      } else if (ballYDirection == direction.UP) {
        ballY -= ballYIncrements;
      }
    });
  }

  ///update direction of the ball
  void updateDirection() {
    setState(() {
      ///ball goes up when it hits the player
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerWidth + playerX) {
        ballYDirection = direction.UP;
      }

      ///ball goes down when it hits the top of screen
      else if (ballY <= -1) {
        ballYDirection = direction.DOWN;
      }

      ///ball goes left when it hits right wall
      if (ballX >= 1) {
        ballXDirection = direction.LEFT;
      }

      ///ball goes right when it hits left wall
      else if (ballX <= -1) {
        ballXDirection = direction.RIGHT;
      }
    });
  }

  ///is player dead
  bool isPlayerDead() {
    ///player dies if ball reaches bottom of the screen
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  ///check for broken bricks
  void checkForBrokenBricks() {
    ///checks when boll hits brick
    for (int i = 0; i < myBricks.length; i++) {
      if (ballX >= myBricks[i][0] &&
          ballX <= myBricks[i][0] + brickWidth &&
          ballY <= myBricks[i][1] + brickHeight &&
          myBricks[i][2] == false) {
        setState(() {
          myBricks[i][2] = true;

          ///since brick is broken, update the direction of ball
          ///based on which side of the brick it hit
          ///to do this, calculate the distance of the ball from each 4 sides.
          double leftSideDist = (myBricks[i][0] - ballX).abs();
          double rightSideDist = (myBricks[i][0] + brickWidth - ballX).abs();
          double topSideDist = (myBricks[i][1] - ballY).abs();
          double bottomSideDist = (myBricks[i][1] + brickHeight - ballY).abs();

          String min =
              findMin(leftSideDist, rightSideDist, topSideDist, bottomSideDist);
          switch (min) {
            case 'left':
              //if ball hit left side of brick then
              ballXDirection = direction.LEFT;
              break;
            case 'right':
              //if ball hit left side of brick then
              ballXDirection = direction.RIGHT;
              break;
            case 'top':
              //if ball hit left side of brick then
              ballYDirection = direction.UP;
              break;
            case 'bottom':
              //if ball hit left side of brick then
              ballYDirection = direction.DOWN;
              break;
          }
        });
      }
    }
  }

  ///find min(return the smallest side
  String findMin(double a, double b, double c, double d) {
    List<double> myList = [a, b, c, d];
    double currentMin = a;

    for (int i = 0; i < myList.length; i++) {
      if (myList[i] < currentMin) {
        currentMin = myList[i];
      }
    }

    if ((currentMin - a).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - b).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - c).abs() < 0.01) {
      return 'top';
    } else if ((currentMin - d).abs() < 0.01) {
      return 'bottom';
    }

    return '';
  }

  ///move player left
  void moveLeft() {
    setState(() {
      ///only move left if moving left doesn't move player off the screen
      if (!(playerX - 0.2 < -1)) {
        playerX -= 0.2;
      }
    });
  }

  ///move player right
  void moveRight() {
    setState(() {
      ///only move right if moving right doesn't move player off the screen
      if (!(playerX + playerWidth >= 1)) {
        playerX += 0.2;
      }
    });
  }

  ///reset game back to initial values when user hits play again
  void resetGame() {
    setState(() {
      ballX = 0;
      ballY = 0;
      playerX = -0.2;
      isGameOver = false;
      hasGameStarted = false;
      myBricks = [
        ///[x, y, broken]
        [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[100],
          body: Center(
            child: Stack(
              children: [
                ///Tap to Play
                CoverScreen(
                  hasGameStarted: hasGameStarted,
                  isGameOver: isGameOver,
                ),

                ///game Over Screen
                GameOverScreen(
                  isGameOver: isGameOver,
                  function: resetGame,
                ),

                ///Ball
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                  isGameOver: isGameOver,
                  hasGameStarted: hasGameStarted,
                ),

                ///Player
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),

                ///bricks
                MyBrick(
                  brickX: myBricks[0][0],
                  brickY: myBricks[0][1],
                  brickBroken: myBricks[0][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
                MyBrick(
                  brickX: myBricks[1][0],
                  brickY: myBricks[1][1],
                  brickBroken: myBricks[1][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
                MyBrick(
                  brickX: myBricks[2][0],
                  brickY: myBricks[2][1],
                  brickBroken: myBricks[2][2],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
