import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateStrip extends StatefulWidget {
  final DateTime start; // início da janela (ex.: hoje - 3d)
  final int days;       // quantos dias renderizar (ex.: 14)
  final ValueChanged<DateTime> onSelected;
  final DateTime? initialSelected;

  const DateStrip({
    super.key,
    required this.start,
    this.days = 14,
    required this.onSelected,
    this.initialSelected,
  });

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _controller;
  late DateTime _selected;
  bool _scrollUnlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _selected = (widget.initialSelected ?? DateTime.now());
    // normaliza _selected para meia-noite
    _selected = DateTime(_selected.year, _selected.month, _selected.day);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _unlockScroll() {
    if (!_scrollUnlocked) {
      setState(() => _scrollUnlocked = true);
    }
  }

  void _jumpBy(int offset) {
    // rola "uma tela" para esquerda/direita
    final width = MediaQuery.of(context).size.width;
    final target = (_controller.offset + (offset * (width * 0.8)))
        .clamp(_controller.position.minScrollExtent, _controller.position.maxScrollExtent);
    _controller.animateTo(target, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag(); // respeita pt_BR/en
    final dates = List.generate(widget.days, (i) => widget.start.add(Duration(days: i)));

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _jumpBy(-1),
              ),
              Expanded(
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    physics: _scrollUnlocked
                        ? const BouncingScrollPhysics(parent: ClampingScrollPhysics())
                        : const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, idx) {
                      final d = dates[idx];
                      final isSelected = _isSameDay(d, _selected);
                      final dow = DateFormat.E(locale).format(d);     // “Seg”
                      final day = DateFormat.d(locale).format(d);      // “22”
                      final mon = DateFormat.MMM(locale).format(d);    // “set.”

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _unlockScroll();
                          setState(() => _selected = d);
                          widget.onSelected(d);
                        },
                        child: Container(
                          width: 84, // largura fixa p/ manter ritmo
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(dow,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 2),
                              Text('$day ${mon.replaceAll('.', '')}',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              // indicador
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 3,
                                width: isSelected ? 40 : 0,
                                decoration: BoxDecoration(
                                  color: isSelected ? cs.secondary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _jumpBy(1),
              ),
            ],
          ),
          // hairline igual ao mock
          Container(height: 1, color: cs.secondary.withOpacity(.25)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
