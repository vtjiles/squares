import 'dart:math';

import 'package:example/game_config.dart';
import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:squares/squares.dart';

class GameCreator extends StatefulWidget {
  final PieceSet pieceSet;
  final Function(GameConfig) onCreate;
  const GameCreator({Key? key, required this.pieceSet, required this.onCreate}) : super(key: key);

  @override
  State<GameCreator> createState() => _GameCreatorState();
}

class _GameCreatorState extends State<GameCreator> {
  List<bishop.Variant> variants = [
    bishop.Variant.standard(),
    bishop.Variant.chess960(),
    bishop.Variant.mini(),
    bishop.Variant.micro(),
    bishop.Variant.nano(),
    bishop.Variant.grand(),
    bishop.Variant.capablanca(),
    bishop.Variant.crazyhouse(),
    // bishop.Variant.seirawan(),
  ];

  List<DropdownMenuItem<int>> get _variantDropdownItems {
    List<DropdownMenuItem<int>> items = [];
    variants.asMap().forEach((k, v) => items.add(DropdownMenuItem(value: k, child: Text(v.name))));
    return items;
  }

  static int variant = 0;
  void _setVariant(int? v) => setState(() => variant = v ?? variant);

  // 0 - white, 1 - random, 2 - black
  static int colour = 1;
  void _changeColour(int c) => setState(() => colour = c);

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int _colour = colour == 0
          ? 0
          : colour == 2
              ? 1
              : Random().nextInt(2);
      if (fen?.isEmpty ?? false) fen = null;
      final config = GameConfig(variant: variants[variant], humanPlayer: _colour, fen: fen);
      widget.onCreate(config);
    }
  }

  final _formKey = GlobalKey<FormState>();

  static String? fen;
  TextEditingController _fenController = TextEditingController(text: fen);

  bool _validateFen(String fen, bishop.Variant? variant) {
    if (variant == null) variant = bishop.Variant.standard();
    return bishop.validateFen(variant: variant, fen: fen);
  }

  void _clearFen() {
    _fenController.clear();
    setState(() => fen = null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(height: 32),
          Text(
            'Game Setup',
            style: Theme.of(context).textTheme.headline5,
          ),
          Divider(),
          DropdownButton<int>(
            value: variant,
            items: _variantDropdownItems,
            onChanged: _setVariant,
          ),
          ToggleButtons(
            children: [
              Container(
                width: 32,
                height: 32,
                child: widget.pieceSet.piece(context, 'K'),
              ),
              Icon(
                MdiIcons.helpCircleOutline,
                size: 30,
              ),
              Container(
                width: 32,
                height: 32,
                child: widget.pieceSet.piece(context, 'k'),
              ),
            ],
            isSelected: [colour == 0, colour == 1, colour == 2],
            onPressed: _changeColour,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _fenController,
              decoration: InputDecoration(
                icon: const Icon(MdiIcons.checkerboard),
                hintText: 'Leave blank for default position',
                labelText: 'Start position (FEN)',
                suffixIcon: _fenController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearFen,
                        icon: Icon(Icons.clear),
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                if (!_validateFen(value, variants[variant])) {
                  return 'Invalid FEN';
                }
                return null;
              },
              onSaved: (value) => fen = value,
            ),
          ),
          ElevatedButton(
            onPressed: _save,
            child: Text('Create Game'),
          ),
        ],
      ),
    );
  }
}
