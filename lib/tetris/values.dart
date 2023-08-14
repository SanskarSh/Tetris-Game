import 'dart:ui';

enum Tetromino { L, J, I, O, S, Z, T }

enum Direction { left, right, down }

// grid dimension
int rowLength = 10, colLength = 15;

Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: const Color(0xFFFFA500), // Orange
  Tetromino.J: const Color.fromARGB(255, 0, 102, 255), // Blue
  Tetromino.I: const Color.fromARGB(255, 242, 0, 255), // Pink
  Tetromino.O: const Color(0xFFFFFF00), // Yellow
  Tetromino.S: const Color(0xFF008000), // Green
  Tetromino.Z: const Color(0xFFFF0000), // Red
  Tetromino.T: const Color.fromARGB(255, 144, 0, 255), // Purple
};
