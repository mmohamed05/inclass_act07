import 'package:flutter/material.dart';
import 'pet_personality/pet_personality.dart';

// PREVIEW ONLY: sliders inject fixtures; they are not Team 1's care rules.
// Copy lib/pet_personality/ into the shared app, not this preview entry point.
void main() => runApp(MaterialApp(
      title: 'Pet personality preview',
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff235b50), useMaterial3: true),
      home: const PersonalityPreview(),
    ));

class PersonalityPreview extends StatefulWidget {
  const PersonalityPreview({super.key});
  @override
  State<PersonalityPreview> createState() => _PersonalityPreviewState();
}

class _PersonalityPreviewState extends State<PersonalityPreview> {
  int _happiness = 50, _hunger = 50, _energy = 70;
  int _actionRevision = 0, _sessionRevision = 0;
  bool _showEnergy = false, _reduceMotion = false;
  String _name = 'Pip';
  PetAction? _lastAction;
  PetOutcome _outcome = PetOutcome.playing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personality preview')),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(children: [
            const Text(
                'Preview fixtures only. Connect the panel to the care system in the shared app.'),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  disableAnimations: _reduceMotion ||
                      MediaQuery.of(context).disableAnimations),
              child: PetPersonalityPanel(
                pet: PetSnapshot(
                    name: _name,
                    happiness: _happiness,
                    hunger: _hunger,
                    energy: _showEnergy ? _energy : null,
                    outcome: _outcome),
                lastAction: _lastAction,
                actionRevision: _actionRevision,
                sessionRevision: _sessionRevision,
              ),
            ),
            TextFormField(
                initialValue: _name,
                decoration:
                    const InputDecoration(labelText: 'Preview pet name'),
                onFieldSubmitted: (value) => setState(() => _name = value)),
            _slider('Happiness', _happiness, (v) => _happiness = v),
            _slider('Hunger', _hunger, (v) => _hunger = v),
            SwitchListTile(
                title: const Text('Include energy'),
                value: _showEnergy,
                onChanged: (v) => setState(() => _showEnergy = v)),
            if (_showEnergy) _slider('Energy', _energy, (v) => _energy = v),
            SwitchListTile(
                title: const Text('Preview reduced motion'),
                value: _reduceMotion,
                onChanged: (v) => setState(() => _reduceMotion = v)),
            Wrap(
                spacing: 8,
                children: PetOutcome.values
                    .map((outcome) => ChoiceChip(
                          label: Text(outcome.name),
                          selected: _outcome == outcome,
                          onSelected: (_) => setState(() => _outcome = outcome),
                        ))
                    .toList()),
            Wrap(
                spacing: 8,
                children: PetAction.values
                    .map((action) => OutlinedButton(
                          onPressed: _outcome != PetOutcome.playing
                              ? null
                              : () => setState(() {
                                    _lastAction = action;
                                    _actionRevision++;
                                  }),
                          child: Text('Preview ${action.name}'),
                        ))
                    .toList()),
            TextButton(
                onPressed: () => setState(() {
                      _happiness = 50;
                      _hunger = 50;
                      _energy = 70;
                      _outcome = PetOutcome.playing;
                      _lastAction = null;
                      _sessionRevision++;
                    }),
                child: const Text('Reset preview')),
          ]),
        )),
      )),
    );
  }

  Widget _slider(String label, int value, void Function(int) assign) => Column(
        children: [
          Text('$label: $value'),
          Slider(
              value: value.toDouble(),
              max: 100,
              divisions: 100,
              label: '$value',
              onChanged: (v) => setState(() => assign(v.round())))
        ],
      );
}
