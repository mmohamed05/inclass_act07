import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_personality/pet_personality.dart';

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

  String _petName = 'Pip';
  PetAction? _personalityLastAction;
  int _personalityActionRevision = 0;
  int _personalitySessionRevision = 0;
  bool _isPaused = false;

  bool _gameOver = false;
  bool _hasWon = false;

  Timer? _hungerTimer;
  Timer? _highMoodTimer;

  int _clampMeter(int value) {
    return value.clamp(0, 100).toInt();
  }

  void _feedPet() {
    if (_gameOver || _hasWon || _isPaused) return;

    final nextHunger = _clampMeter(_hunger - 10);
    final happinessChange = nextHunger < 30 ? -20 : 10;
    final nextHappiness = _clampMeter(_happiness + happinessChange);

    setState(() {
      _hunger = nextHunger;
      _happiness = nextHappiness;
      _personalityLastAction = PetAction.feed;
      _personalityActionRevision++;
    });

    _updateOutcome();
  }

  void _playPet() {
    if (_gameOver || _hasWon || _isPaused) return;

    setState(() {
      _happiness = _clampMeter(_happiness + 15);
      _hunger = _clampMeter(_hunger + 5);
      _personalityLastAction = PetAction.play;
      _personalityActionRevision++;
    });

    _updateOutcome();
  }

  void _updateOutcome() {
    if (_gameOver || _hasWon || _isPaused) return;

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

      if (!mounted || _gameOver || _hasWon || _isPaused || _happiness <= 80) {
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
    _hungerTimer = null;
    if (_isPaused || _gameOver || _hasWon) return;

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted || _gameOver || _hasWon || _isPaused) {
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

  void _togglePause() {
    if (_gameOver || _hasWon) return;

    _hungerTimer?.cancel();
    _hungerTimer = null;
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) _personalitySessionRevision++;
    });

    if (!_isPaused) {
      _startHungerTimer();
      // Pausing interrupts continuous high mood; resume starts a full interval.
      _updateOutcome();
    }
  }

  void _resetPet() {
    _highMoodTimer?.cancel();
    _highMoodTimer = null;

    setState(() {
      _happiness = 50;
      _hunger = 50;
      _gameOver = false;
      _hasWon = false;
      _isPaused = false;
      _personalityLastAction = null;
      _personalitySessionRevision++;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet')),
      body: PetCareView(
        pet: PetSnapshot(
          name: _petName,
          happiness: _happiness,
          hunger: _hunger,
          outcome: _gameOver
              ? PetOutcome.lost
              : _hasWon
              ? PetOutcome.won
              : PetOutcome.playing,
        ),
        onFeed: _feedPet,
        onPlay: _playPet,
        onReset: _resetPet,
        onNameConfirmed: (name) => setState(() => _petName = name),
        lastAction: _personalityLastAction,
        actionRevision: _personalityActionRevision,
        sessionRevision: _personalitySessionRevision,
        paused: _isPaused,
        onTogglePause: _togglePause,
      ),
    );
  }
}
