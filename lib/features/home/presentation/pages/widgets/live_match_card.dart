import 'package:flutter/material.dart';
import 'package:handscore/core/theme/layout_breakpoints.dart';
import 'package:handscore/l10n/app_localizations.dart';

class LiveMatchCard extends StatelessWidget {
  final String league;
  final String home;
  final String away;
  final String score;
  final String minuteBadge;
  final VoidCallback onDetails;

  const LiveMatchCard({
    super.key,
    required this.league,
    required this.home,
    required this.away,
    required this.score,
    required this.minuteBadge,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = LayoutBreakpoints.cardRadius(context);
    final s = S.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    league,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    minuteBadge,
                    style: TextStyle(
                      color: cs.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _team(context, home, alignEnd: false)),
                Text(
                  score,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(child: _team(context, away, alignEnd: true)),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onDetails,
              child: Text(s.details),
            ),
          ],
        ),
      ),
    );
  }

  Widget _team(BuildContext context, String name, {required bool alignEnd}) {
    final textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(radius: 16),
        const SizedBox(width: 8),
        // protege contra overflow e força 1 linha
        Flexible(
          child: Text(
            name,
            textAlign: textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
