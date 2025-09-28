import 'package:flutter/material.dart';
import 'package:handscore/l10n/app_localizations.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeMore;
  const SectionHeader({super.key, required this.title, this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (onSeeMore != null)
          TextButton(
            onPressed: onSeeMore,
            child: Text(S.of(context).seeMore, style: TextStyle(color: cs.secondary)),
          ),
      ],
    );
  }
}
