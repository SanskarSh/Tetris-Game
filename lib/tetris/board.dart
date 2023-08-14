import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'piece.dart';
import 'pixel.dart';
import 'values.dart';

/*

GAME BOARD
This is a 2x2 grid with null represent ing an empty space.
A non empty space will have the color to represent the landed pieces

*/

// create game board
List<List<Tetromino?>> gameBoard = List.generate(
    colLength,
    (i) => List.generate(
          rowLength,
          (j) => null,
        ));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);

  // current score
  int currentScore = 0;

  // game over status
  bool gameOver = false;

  bool isPlaying = false;

  void startGame() {
    currentPiece.initializePiece();

    // frame refresh rate
    Duration frameRate = const Duration(milliseconds: 500);
    gameLoop(frameRate);
  }

  // game loop
  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        Vibration.hasVibrator()
            .then((value) => Vibration.vibrate(duration: 20));

        isPlaying = true;
        // clear lines
        clearLines();

        // check Landing
        checkLanding();

        // check if game is over
        if (gameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        // move current piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  bool checkCollision(Direction direction) {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the row and column of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // check if the piece is out of bounds(either too low or too far to the left or right)
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      // check for collision with existing blocks on the game board
      if (row >= 0 && col >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if no collision is detected
    return false;
  }

  void checkLanding() {
    // if going down is occupied or landed on other pieces
    if (checkCollision(Direction.down) || checkLanded()) {
      // mark position as occupied on the game board
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // once landed, create the next piece
      createNewPiece();
    }
  }

  bool checkLanded() {
    // loop through each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // check if the cell below is already occupied
      if (row + 1 < colLength && row >= 0 && gameBoard[row + 1][col] != null) {
        return true; // collision with a landed piece
      }
    }

    return false; // no collision with landed pieces
  }

  void createNewPiece() {
    // create a random object to generate random tetromino type
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    /*

    Since our game over condition is if there is a piece at the top level,
    you want to check if the game is over when you create a new piece
    instead of checking every frame, because new pieces are allowed to go through the top level
    but if there is already a piece in the top level when the new piece is created,
    then game is over

    */
    if (isGameOver()) {
      gameOver = true;
    }
  }

  // move left
  void moveLeft() {
    // make sure the move is valid before moving there
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
        Vibration.hasVibrator()
            .then((value) => Vibration.vibrate(duration: 30));
      });
    }
  }

  // rotate piece
  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
      Vibration.hasVibrator().then((value) => Vibration.vibrate(duration: 30));
    });
  }

  // move right
  void moveRight() {
    // make sure the move is valid before moving there
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
        Vibration.hasVibrator()
            .then((value) => Vibration.vibrate(duration: 30));
      });
    }
  }

  // clear lines
  void clearLines() {
    // step 1: Loop through each row of the game board from bottom to top
    for (int row = colLength - 1; row >= 0; row--) {
      // step 2: Initialize a variable to track if the row is full
      bool rowIsFull = true;
      // step 3: Check if the row if full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there's an empty column, set rowlsFult to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: if the row is full, clear the row and shift rows down
      if (rowIsFull) {
        // step 5: move all rows above the cleared row down by one position
        for (int r = row; r > 0; r--) {
          // copy the above row to the current row
          gameBoard[r] = List.from(gameBoard[r - 1]);

          // step 6: set top row to empty
          gameBoard[0] = List.generate(row, (index) => null);
        }
        // step 7: Increase the score
        currentScore++;
      }
    }
  }

  bool isGameOver() {
    // Check if all columns in the top row are filled
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true; // If any block is empty, game is not over
      }
    }
    return false; // All blocks in the top row are filled
  }

  // game over message
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.amber,
        title: const Text('Game Over!'),
        content: Text('You Scored: $currentScore'),
        actions: [
          TextButton(
              onPressed: () {
                // reset the game
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'))
        ],
      ),
    );
  }

  // reset game
  void resetGame() {
    // clear the game board
    gameBoard =
        List.generate(colLength, (i) => List.generate(rowLength, (j) => null));

    // new game
    gameOver = false;
    currentScore = 0;

    // create new piece
    createNewPiece();

    // Start game again
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // SCORE
          Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Card(
                  color: Colors.black,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Current Score ',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          '$currentScore',
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          // GAME
          Expanded(
            flex: 15,
            child: GridView.builder(
              itemCount: rowLength * colLength,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                // get row and col of each index
                int row = (index / rowLength).floor();
                int col = index % rowLength;
                // current piece
                if (currentPiece.position.contains(index)) {
                  return Pixel(color: currentPiece.color);
                }

                // landed pieces
                else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(color: tetrominoColors[tetrominoType]);
                }

                // blank pixel
                else {
                  return Pixel(color: Colors.black);
                }
              },
            ),
          ),

          // GAME CONTROLs
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // play
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: GestureDetector(
                      onTap: isPlaying ? null : startGame,
                      child: Card(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              isPlaying ? 'Playing' : 'Play',
                              style: const TextStyle(color: Colors.amber),
                            ),
                          )),
                    ),
                  ),

                  // left
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: GestureDetector(
                      onTap: moveLeft,
                      child: const Card(
                        color: Colors.black,
                        child: Icon(
                          Icons.arrow_left_rounded,
                          color: Colors.amber,
                          size: 50,
                        ),
                      ),
                    ),
                  ),

                  // rotate
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: GestureDetector(
                      onTap: rotatePiece,
                      child: const Card(
                        color: Colors.black,
                        child: Icon(
                          Icons.rotate_right,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),

                  // right
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: GestureDetector(
                      onTap: moveRight,
                      child: const Card(
                        color: Colors.black,
                        child: Icon(
                          Icons.arrow_right_rounded,
                          color: Colors.amber,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
