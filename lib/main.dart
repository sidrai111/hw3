import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GameState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardMatchingGame(),
    );
  }
}

class CardModel {
  final String value;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.value, this.isFaceUp = false, this.isMatched = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstSelected;
  CardModel? secondSelected;

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> values = ['A', 'A', 'B', 'B', 'C', 'C', 'D', 'D', 'E', 'E', 'F', 'F', 'G', 'G', 'H', 'H'];
    values.shuffle();
    cards = values.map((val) => CardModel(value: val)).toList();
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (card.isMatched || card.isFaceUp) return;
    
    card.isFaceUp = true;
    notifyListeners();

    if (firstSelected == null) {
      firstSelected = card;
    } else {
      secondSelected = card;
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (firstSelected != null && secondSelected != null) {
      if (firstSelected!.value == secondSelected!.value) {
        firstSelected!.isMatched = true;
        secondSelected!.isMatched = true;
        firstSelected = null;
        secondSelected = null;
      } else {
        Future.delayed(Duration(seconds: 1), () {
          firstSelected!.isFaceUp = false;
          secondSelected!.isFaceUp = false;
          firstSelected = null;
          secondSelected = null;
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Card Matching Game')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: gameState.cards.length,
        itemBuilder: (context, index) {
          final card = gameState.cards[index];
          return GestureDetector(
            onTap: () => gameState.flipCard(card),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: card.isFaceUp ? Colors.white : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  card.isFaceUp ? card.value : '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
