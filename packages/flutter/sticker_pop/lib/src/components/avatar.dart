import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../theme/pop_text.dart';
import '../tokens/pop_tokens.g.dart';

const List<Color> _fills = <Color>[
  PopColors.yellow,
  PopColors.pink,
  PopColors.blue,
  PopColors.mint,
  PopColors.lilac,
  PopColors.orange,
];

/// Up to two initials: the first letters of the first and last words.
String popInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  final first = words.first.characters.first;
  final last = words.length > 1 ? words.last.characters.first : '';
  return (first + last).toUpperCase();
}

/// The bright a name always gets (the same on every platform): the sum of
/// its UTF-16 code units, modulo the six brights.
Color popAvatarColor(String name) =>
    _fills[name.trim().codeUnits.fold<int>(0, (a, b) => a + b) % _fills.length];

/// A person, payee or shared account: their initials in a bright circle with
/// a 2 ink outline. The colour comes from the name, so it stays put. Sizes:
/// 32 (in chips and lists of people), 42 (rows, the default), 56 (profiles).
class PopAvatar extends StatelessWidget {
  const PopAvatar({super.key, required this.name, this.size = 42, this.color});

  final String name;
  final double size;

  /// Overrides the colour picked from the name.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      image: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? popAvatarColor(name),
          shape: BoxShape.circle,
          border: popOutline(PopBorder.thin),
        ),
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: MediaQuery.withNoTextScaling(
              child: Text(
                popInitials(name),
                style: popText(
                  size * 0.38,
                  weight: FontWeight.w800,
                ).copyWith(height: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
