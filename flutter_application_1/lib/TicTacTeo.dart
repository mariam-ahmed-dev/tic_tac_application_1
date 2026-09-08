import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PickPlayerScreen(),
    );
  }
}

const Color gradientStart = Color(0xFFEA9E23);
const Color gradientEnd = Color(0xFFE52E2E);
const Color redXColor = Color(0xFFE52E2E);
const Color greenOColor = Color(0xFF4CAF50);

class PickPlayerScreen extends StatelessWidget {
  const PickPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Tic-Tac-Toe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Text(
                'Pick who goes first?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChoiceCard(
                    context: context,
                    symbol: 'X',
                    color: redXColor,
                    onTap: () => _startGame(context, 'X'),
                  ),
                  const SizedBox(width: 20),
                  _buildChoiceCard(
                    context: context,
                    symbol: 'O',
                    color: greenOColor,
                    onTap: () => _startGame(context, 'O'),
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required String symbol,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, String selectedSymbol) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(firstPlayerSymbol: selectedSymbol),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String firstPlayerSymbol;

  const GameScreen({super.key, required this.firstPlayerSymbol});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String currentTurn;
  List<String> board = List.filled(9, '');
  String winnerText = '';
  bool isGameOver = false;

  Timer? timer;
  int secondsPassed = 0;

  @override
  void initState() {
    super.initState();
    currentTurn = widget.firstPlayerSymbol;
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isGameOver && mounted) {
        setState(() {
          secondsPassed++;
        });
      }
    });
  }

  String get formattedTime {
    int minutes = secondsPassed ~/ 60;
    int seconds = secondsPassed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isGameOver
                      ? winnerText
                      : "Player ${currentTurn == widget.firstPlayerSymbol ? '1' : '2'}'s Turn",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 9,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _handleTap(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: _getCellBorder(index),
                            ),
                            child: Center(
                              child: Text(
                                board[index],
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: board[index] == 'X' ? redXColor : greenOColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (isGameOver)
                  ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: gradientEnd,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      'Play Again',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Border _getCellBorder(int index) {
    int row = index ~/ 3;
    int col = index % 3;
    BorderSide lineSide = const BorderSide(color: Colors.grey, width: 1.5);

    return Border(
      right: col < 2 ? lineSide : BorderSide.none,
      bottom: row < 2 ? lineSide : BorderSide.none,
    );
  }

  void _handleTap(int index) {
    if (board[index] == '' && !isGameOver) {
      setState(() {
        board[index] = currentTurn;
        _checkWinner();
        if (!isGameOver) {
          currentTurn = currentTurn == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  void _checkWinner() {
    List<List<int>> winLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var line in winLines) {
      if (board[line[0]] != '' &&
          board[line[0]] == board[line[1]] &&
          board[line[0]] == board[line[2]]) {
        String winnerSymbol = board[line[0]];
        String playerNumber = winnerSymbol == widget.firstPlayerSymbol ? '1' : '2';
        setState(() {
          isGameOver = true;
          winnerText = "Player $playerNumber Wins!";
        });
        return;
      }
    }

    if (!board.contains('')) {
      setState(() {
        isGameOver = true;
        winnerText = "It's a Draw!";
      });
    }
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isGameOver = false;
      winnerText = '';
      secondsPassed = 0;
      currentTurn = widget.firstPlayerSymbol;
    });
  }
}