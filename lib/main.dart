import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Pet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DigitalPetPage(),
    );
  }
}

class DigitalPetPage extends StatefulWidget {
  const DigitalPetPage({super.key});

  @override
  State<DigitalPetPage> createState() => _DigitalPetPageState();
}

class _DigitalPetPageState extends State<DigitalPetPage> {
  int _happiness = 50;
  int _hunger = 50;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  String get _outcomeText {
    if (_hasWon) return 'You win!';
    if (_gameOver) return 'Game over';
    return 'Take care of your pet';
  }

  void _feedPet() {
    if (_gameOver || _hasWon) return;

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;
    final nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
    });

    _updateOutcome();
  }

  void _playPet() {
    if (_gameOver || _hasWon) return;

    setState(() {
      _happiness = _clampMeter(_happiness + 15);
      _hunger = _clampMeter(_hunger + 5);
    });

    _updateOutcome();
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon) return;

    if (_hunger == 100 && _happiness <= 10) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      _hungerTimer?.cancel();

      setState(() {
        _gameOver = true;
      });

      return;
    }

    if (_happiness <= 80) {
      _highMoodTimer?.cancel();
      _highMoodTimer = null;
      return;
    }

    _highMoodTimer ??= Timer(const Duration(minutes: 3), () {
      _highMoodTimer = null;

      if (!mounted || _gameOver || _happiness <= 80) {
        return;
      }

      setState(() {
        _hasWon = true;
      });

      _hungerTimer?.cancel();
    });
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_hunger + 5 > 100) {
          _hunger = 100;
          _happiness = _clampMeter(_happiness - 20);
        } else {
          _hunger += 5;
        }
      });

      _updateOutcome();
    });
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
    });

    _startHungerTimer();
  }

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _highMoodTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionsDisabled = _gameOver || _hasWon;

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 100),
            const SizedBox(height: 24),
            Text(
              _outcomeText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            Text('Happiness: $_happiness'),
            LinearProgressIndicator(value: _happiness / 100),
            const SizedBox(height: 24),
            Text('Hunger: $_hunger'),
            LinearProgressIndicator(value: _hunger / 100),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: actionsDisabled ? null : _feedPet,
                  child: const Text('Feed'),
                ),
                ElevatedButton(
                  onPressed: actionsDisabled ? null : _playPet,
                  child: const Text('Play'),
                ),
                ElevatedButton(
                  onPressed: _resetPet,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
