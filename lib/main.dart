import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const int snakeInitialLength = 5;

  List<Offset> snake = [];
  Offset direction = Offset(1, 0); // Initial direction: right
  Offset food = generateFood();

  @override
  void initState() {
    super.initState();
    resetGame();
    startGame();
  }

  void resetGame() {
    setState(() {
      snake.clear();
      for (int i = 0; i < snakeInitialLength; i++) {
        snake.add(Offset(i.toDouble(), 0));
      }
      direction = Offset(1, 0); // Initial direction: right
    });
  }

  void startGame() {
    const duration = Duration(milliseconds: 200);

    Timer.periodic(duration, (timer) {
      moveSnake();
      if (checkCollision()) {
        timer.cancel();
        resetGame();
        startGame();
      }
      if (checkFood()) {
        growSnake();
        updateFood();
      }
      setState(() {});
    });
  }

  void moveSnake() {
    setState(() {
      final List<Offset> newSnake = [];
      for (int i = 0; i < snake.length - 1; i++) {
        newSnake.add(snake[i + 1]);
      }
      newSnake.add(snake.last + direction);
      snake = List.from(newSnake);
    });
  }

  bool checkCollision() {
    final head = snake.last;
    return head.dx < 0 ||
        head.dy < 0 ||
        head.dx >= gridSize ||
        head.dy >= gridSize ||
        snake.sublist(0, snake.length - 1).contains(head);
  }

  bool checkFood() {
    final head = snake.last;
    return head == food;
  }

  void growSnake() {
    setState(() {
      snake.insert(0, Offset(-1, -1));
    });
  }

  void updateFood() {
    setState(() {
      food = generateFood();
    });
  }

  static Offset generateFood() {
    final Random random = Random();
    return Offset(random.nextInt(gridSize).toDouble(), random.nextInt(gridSize).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (direction.dy == 0) {
            // Only allow changing direction vertically if currently moving horizontally
            setState(() {
              direction = details.primaryDelta! > 0 ? Offset(0, 1) : Offset(0, -1);
            });
          }
        },
        onHorizontalDragUpdate: (details) {
          if (direction.dx == 0) {
            // Only allow changing direction horizontally if currently moving vertically
            setState(() {
              direction = details.primaryDelta! > 0 ? Offset(1, 0) : Offset(-1, 0);
            });
          }
        },
        child: Container(
          color: Colors.black,
          child: GridView.builder(
            itemCount: gridSize * gridSize,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
            itemBuilder: (BuildContext context, int index) {
              final x = index % gridSize;
              final y = index ~/ gridSize;

              if (snake.contains(Offset(x.toDouble(), y.toDouble()))) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.black),
                  ),
                );
              } else if (food == Offset(x.toDouble(), y.toDouble())) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: Colors.black),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
