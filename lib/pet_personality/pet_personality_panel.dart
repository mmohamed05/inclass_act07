import 'dart:async';
import 'package:flutter/material.dart';
import 'pet_presentation.dart';

/// Appearance and timing knobs. Game thresholds live in PersonalityRules.
class PetAppearance {
  const PetAppearance({
    this.assetPath = 'assets/pet.png',
    this.happyColor = Colors.green,
    this.neutralColor = Colors.yellow,
    this.unhappyColor = Colors.red,
    this.happyScale = 1.06,
    this.neutralScale = 1.0,
    this.unhappyScale = 0.94,
    this.motionDuration = const Duration(milliseconds: 180),
    this.meterDuration = const Duration(milliseconds: 400),
    this.messageDuration = const Duration(milliseconds: 300),
    this.bounceHold = const Duration(milliseconds: 180),
    this.reactionHold = const Duration(milliseconds: 900),
  });
  final String assetPath;
  final Color happyColor, neutralColor, unhappyColor;
  final double happyScale, neutralScale, unhappyScale;
  final Duration motionDuration, meterDuration, messageDuration;
  final Duration bounceHold, reactionHold;

  Color colorFor(PetMood mood) => switch (mood) {
        PetMood.happy => happyColor,
        PetMood.neutral => neutralColor,
        PetMood.unhappy => unhappyColor,
      };
  double scaleFor(PetMood mood) => switch (mood) {
        PetMood.happy => happyScale,
        PetMood.neutral => neutralScale,
        PetMood.unhappy => unhappyScale,
      };
}

/// Drop this widget into the partner's screen. It NEVER changes game values.
/// Increment actionRevision after each accepted action, even repeated feeds.
/// Increment sessionRevision on restart to clear any pending visual feedback.
class PetPersonalityPanel extends StatefulWidget {
  const PetPersonalityPanel({
    super.key,
    required this.pet,
    this.lastAction,
    this.actionRevision = 0,
    this.sessionRevision = 0,
    this.rules = const PersonalityRules(),
    this.appearance = const PetAppearance(),
  });
  final PetSnapshot pet;
  final PetAction? lastAction;
  final int actionRevision, sessionRevision;
  final PersonalityRules rules;
  final PetAppearance appearance;

  @override
  State<PetPersonalityPanel> createState() => _PetPersonalityPanelState();
}

class _PetPersonalityPanelState extends State<PetPersonalityPanel> {
  // Only transient animation state is stored here. Mood/speech are derived.
  Timer? _bounceTimer, _reactionTimer;
  bool _bouncing = false;
  PetAction? _reaction;

  void _clearFeedback() {
    _bounceTimer?.cancel();
    _reactionTimer?.cancel();
    _bounceTimer = null;
    _reactionTimer = null;
    _bouncing = false;
    _reaction = null;
  }

  @override
  void didUpdateWidget(covariant PetPersonalityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessionRevision != oldWidget.sessionRevision ||
        widget.pet.outcome != PetOutcome.playing) {
      _clearFeedback();
    } else if (widget.actionRevision != oldWidget.actionRevision &&
        widget.lastAction != null) {
      // Cancel earlier resets so rapid actions receive a full feedback period.
      _clearFeedback();
      _reaction = widget.lastAction;
      _bouncing = true;
      _bounceTimer = Timer(widget.appearance.bounceHold, () {
        if (!mounted) return;
        setState(() => _bouncing = false);
      });
      _reactionTimer = Timer(widget.appearance.reactionHold, () {
        if (!mounted) return;
        setState(() => _reaction = null);
      });
    }
    // Flutter already schedules build after didUpdateWidget; no setState here.
  }

  @override
  void dispose() {
    _clearFeedback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final appearance = widget.appearance;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final mood = widget.rules.moodFor(pet.happiness);
    final moodLabel = switch (mood) {
      PetMood.happy => 'Happy',
      PetMood.neutral => 'Neutral',
      PetMood.unhappy => 'Unhappy',
    };
    final moodIcon = switch (mood) {
      PetMood.happy => Icons.sentiment_very_satisfied,
      PetMood.neutral => Icons.sentiment_neutral,
      PetMood.unhappy => Icons.sentiment_dissatisfied,
    };
    final message = widget.rules.messageFor(pet);
    final color = appearance.colorFor(mood);
    final name = pet.name.trim().isEmpty ? 'Pip' : pet.name.trim();
    final scale = reduceMotion
        ? 1.0
        : appearance.scaleFor(mood) * (_bouncing ? 1.07 : 1.0);
    final motion = reduceMotion ? Duration.zero : appearance.motionDuration;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
              Icon(moodIcon),
              Text('Mood: $moodLabel',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            SizedBox(
              height: 220,
              child: Center(
                child: AnimatedScale(
                  key: const ValueKey('pet-scale'),
                  scale: scale,
                  duration: motion,
                  curve: Curves.easeOut,
                  child: Semantics(
                    container: true,
                    image: true,
                    label: '$name, $moodLabel pet',
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(color, BlendMode.modulate),
                      child: Image.asset(
                        appearance.assetPath,
                        height: 180,
                        width: 180,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stack) => const Icon(
                            Icons.pets,
                            size: 120,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Reduced motion uses a static replacement, even mid-animation.
            Semantics(
              liveRegion: true,
              label: message,
              excludeSemantics: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: reduceMotion
                      ? Text(message, textAlign: TextAlign.center)
                      : AnimatedSwitcher(
                          duration: appearance.messageDuration,
                          child: Text(message,
                              key: ValueKey(message),
                              textAlign: TextAlign.center),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSlide(
              offset: reduceMotion || _reaction != null
                  ? Offset.zero
                  : const Offset(0, 0.15),
              duration: motion,
              child: AnimatedOpacity(
                opacity: _reaction == null ? 0 : 1,
                duration: motion,
                child: Text(_reactionLabel(_reaction),
                    key: const ValueKey('reaction'),
                    textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(height: 12),
            _Meter(
                label: 'Happiness',
                value: pet.happiness,
                duration: appearance.meterDuration,
                reduceMotion: reduceMotion),
            _Meter(
                label: 'Hunger',
                value: pet.hunger,
                duration: appearance.meterDuration,
                reduceMotion: reduceMotion),
            if (pet.energy != null)
              _Meter(
                  label: 'Energy',
                  value: pet.energy!,
                  duration: appearance.meterDuration,
                  reduceMotion: reduceMotion),
            if (pet.outcome != PetOutcome.playing) ...[
              const SizedBox(height: 12),
              Text(
                  pet.outcome == PetOutcome.won
                      ? 'You won! Restart to play again.'
                      : 'Game over. Restart to try again.',
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

String _reactionLabel(PetAction? action) => switch (action) {
      PetAction.feed => 'Snack time!',
      PetAction.play => 'That was fun!',
      PetAction.rest => 'Rest time...',
      PetAction.pet => 'Thanks for the love!',
      null => ' ',
    };

class _Meter extends StatelessWidget {
  const _Meter(
      {required this.label,
      required this.value,
      required this.duration,
      required this.reduceMotion});
  final String label;
  final int value;
  final Duration duration;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    // Defensive display clamp only; Team 1 must still clamp real game state.
    final bounded = value.clamp(0, 100).toInt();
    final target = bounded / 100.0;
    Widget bar(double amount) => LinearProgressIndicator(
          value: amount,
          minHeight: 8,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Semantics(
        label: label,
        value: '$bounded out of 100',
        excludeSemantics: true,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('$label: $bounded / 100'),
          const SizedBox(height: 6),
          if (reduceMotion)
            bar(target)
          else
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: target, end: target),
              duration: duration,
              curve: Curves.easeOut,
              builder: (context, amount, child) => bar(amount),
            ),
        ]),
      ),
    );
  }
}
