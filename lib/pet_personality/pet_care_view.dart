import 'package:flutter/material.dart';

import 'pet_personality_panel.dart';
import 'pet_presentation.dart';

/// Team 2's complete screen body. Team 1 owns values, actions and timers.
/// Use this as a Scaffold body, passing Team 1's existing action callbacks.
class PetCareView extends StatefulWidget {
  const PetCareView({
    super.key,
    required this.pet,
    required this.onFeed,
    required this.onPlay,
    required this.onReset,
    required this.onNameConfirmed,
    this.lastAction,
    this.actionRevision = 0,
    this.sessionRevision = 0,
    this.paused = false,
    this.onTogglePause,
    this.rules = const PersonalityRules(),
    this.appearance = const PetAppearance(),
  });

  final PetSnapshot pet;
  final VoidCallback onFeed, onPlay, onReset;
  final ValueChanged<String> onNameConfirmed;
  final PetAction? lastAction;
  final int actionRevision, sessionRevision;
  final bool paused;
  // Optional UI only. The care layer must implement pause/resume timer rules.
  final VoidCallback? onTogglePause;
  final PersonalityRules rules;
  final PetAppearance appearance;

  @override
  State<PetCareView> createState() => _PetCareViewState();
}

class _PetCareViewState extends State<PetCareView> {
  late final TextEditingController _nameController;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
  }

  @override
  void didUpdateWidget(covariant PetCareView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.name != widget.pet.name) {
      _nameController.text = widget.pet.name;
      _nameError = null;
    }
  }

  void _confirmName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a pet name.');
      return;
    }
    setState(() => _nameError = null);
    FocusScope.of(context).unfocus();
    widget.onNameConfirmed(name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ended = widget.pet.outcome != PetOutcome.playing;
    final disabled = ended || widget.paused;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PetPersonalityPanel(
                  pet: widget.pet,
                  lastAction: widget.lastAction,
                  actionRevision: widget.actionRevision,
                  sessionRevision: widget.sessionRevision,
                  rules: widget.rules,
                  appearance: widget.appearance,
                ),
                const SizedBox(height: 12),
                if (widget.paused && !ended)
                  const Text('Paused', textAlign: TextAlign.center),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: disabled ? null : widget.onFeed,
                      child: const Text('Feed'),
                    ),
                    ElevatedButton(
                      onPressed: disabled ? null : widget.onPlay,
                      child: const Text('Play'),
                    ),
                    if (widget.onTogglePause != null)
                      ElevatedButton(
                        onPressed: ended ? null : widget.onTogglePause,
                        child: Text(widget.paused ? 'Resume' : 'Pause'),
                      ),
                    ElevatedButton(
                      onPressed: widget.onReset,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  maxLength: 24,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Pet name',
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _confirmName(),
                ),
                OutlinedButton(
                  onPressed: _confirmName,
                  child: const Text('Confirm name'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
