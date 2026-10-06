/// Team 1 owns the real game state. Construct this read-only snapshot in build().
/// Null energy means the combined app does not use the Energy feature.
class PetSnapshot {
  const PetSnapshot({
    required this.name,
    required this.happiness,
    required this.hunger,
    this.energy,
    this.outcome = PetOutcome.playing,
  });

  final String name;
  final int happiness;
  final int hunger;
  final int? energy;
  final PetOutcome outcome;
}

enum PetOutcome { playing, won, lost }

enum PetMood { unhappy, neutral, happy }

enum PetAction { feed, play, rest, pet }

/// Edit these thresholds/messages in one place, without changing game rules.
/// Defaults match the assignment's examples (speech <=30; red tint <30).
class PersonalityRules {
  const PersonalityRules({
    this.unhappyBelow = 30,
    this.happyAbove = 70,
    this.hungryAbove = 80,
    this.askToPlayAtOrBelow = 30,
    this.sleepyBelow = 20,
    this.lostMessage = 'I need a rest.',
    this.wonMessage = 'Best day ever!',
    this.hungryMessage = "I'm starving!",
    this.playMessage = 'Play with me?',
    this.sleepyMessage = 'So sleepy...',
  }) : assert(unhappyBelow <= happyAbove);

  final int unhappyBelow, happyAbove, hungryAbove;
  final int askToPlayAtOrBelow, sleepyBelow;
  final String lostMessage,
      wonMessage,
      hungryMessage,
      playMessage,
      sleepyMessage;

  PetMood moodFor(int happiness) {
    if (happiness > happyAbove) return PetMood.happy;
    if (happiness < unhappyBelow) return PetMood.unhappy;
    return PetMood.neutral;
  }

  String messageFor(PetSnapshot pet) {
    if (pet.outcome == PetOutcome.lost) return lostMessage;
    if (pet.outcome == PetOutcome.won) return wonMessage;
    if (pet.hunger > hungryAbove) return hungryMessage;
    if (pet.happiness <= askToPlayAtOrBelow) return playMessage;
    if (pet.energy != null && pet.energy! < sleepyBelow) return sleepyMessage;
    final name = pet.name.trim().isEmpty ? 'Pip' : pet.name.trim();
    return "Hi, I'm $name!";
  }
}
