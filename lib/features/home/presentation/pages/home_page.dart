import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handscore/features/auth/data/ui/account_tab.dart';
import 'package:handscore/features/home/presentation/pages/widgets/section_header.dart';
import 'package:handscore/core/theme/layout_breakpoints.dart';
import 'package:handscore/l10n/app_localizations.dart';
import 'package:handscore/features/home/presentation/pages/widgets/live_match_card.dart';
import 'package:handscore/core/utils/team_name.dart';
import 'package:handscore/features/home/presentation/pages/widgets/date_strip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final padding = LayoutBreakpoints.pagePadding(context);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HandScores'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(74),
          child: DateStrip(
            start: DateTime.now().subtract(const Duration(days: 3)),
            days: 14,
            initialSelected: _selectedDate,
            onSelected: (d) {
              setState(() => _selectedDate = d);
              // TODO: refetch jogos do dia selecionado
            },
          ),
        ),
      ),
      body: Padding(padding: padding, child: _buildTabContent(context)),
      bottomNavigationBar: _bottomBar(context, s),
    );
  }

  Widget _bottomBar(BuildContext context, S s) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: _tabIndex,
      onDestinationSelected: (i) => setState(() => _tabIndex = i),
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: cs.secondary.withOpacity(.12),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_filled),
          label: s.homeTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.emoji_events_outlined),
          label: s.competitionTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.article_outlined),
          label: s.newsTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          label: s.accountTab,
        ),
      ],
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_tabIndex) {
      case 0:
        return _homeTab(context);
      case 1:
        return Center(child: Text(S.of(context).competitionTab));
      case 2:
        return Center(child: Text(S.of(context).newsTab));
      case 3:
        return const  AccountTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _homeTab(BuildContext context) {
    final s = S.of(context);

    // dados mockados — finitos (SEM loop) para o carrossel
    final liveItems = [
      LiveCardData(
        league: s.premierLeague,
        home: s.nottinghamForest,
        away: s.manUnited,
        score: '0 - 2',
        minuteBadge: "78'",
        onDetails: () => context.go('/match/abc123'),
      ),
      LiveCardData(
        league: 'La Liga',
        home: 'Sevilla',
        away: 'Barcelona',
        score: '1 - 2',
        minuteBadge: "65'",
        onDetails: () => context.go('/match/def456'),
      ),
      LiveCardData(
        league: 'Bundesliga',
        home: 'Bayern',
        away: 'Dortmund',
        score: '2 - 2',
        minuteBadge: "54'",
        onDetails: () => context.go('/match/ghi789'),
      ),
    ];

    return ListView(
      children: [
        SectionHeader(title: s.liveNow, onSeeMore: () {}),
        const SizedBox(height: 12),

        // ======== CARROSSEL HORIZONTAL COM SNAP ========
        _LiveNowCarousel(items: liveItems),

        const SizedBox(height: 24),
        SectionHeader(title: s.score, onSeeMore: () {}),
        const SizedBox(height: 12),

        // lista de placares finalizados
        ...List.generate(4, (i) => _finishedMatchTile(context, i)),
      ],
    );
  }

  Widget _finishedMatchTile(BuildContext context, int idx) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).cardTheme.color;
    final s = S.of(context);

    final home = shortTeam('West Ham United');
    final away = shortTeam('Arsenal');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          LayoutBreakpoints.cardRadius(context),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.sports_handball),
        title: Text(
          '$home  ${idx + 1}  x  ${idx + 2}  $away',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          '${s.ftShort} • 15/4',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: cs.onSurface.withOpacity(.6),
        ),
        onTap: () {},
      ),
    );
  }
}

class _LiveNowCarousel extends StatefulWidget {
  final List<LiveCardData> items;
  const _LiveNowCarousel({required this.items});

  @override
  State<_LiveNowCarousel> createState() => _LiveNowCarouselState();
}

class _LiveNowCarouselState extends State<_LiveNowCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    // viewportFraction < 1.0 mostra parte do próximo card (efeito carrossel)
    _controller = PageController(viewportFraction: 0.86, initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsivo: altura da linha de cards
    final form = LayoutBreakpoints.of(context);
    final height = switch (form) {
      FormFactor.desktop => 240.0,
      FormFactor.tablet => 220.0,
      FormFactor.mobile => 210.0,
    };

    // Não é infinito: usamos PageView com itemCount finito.
    // "Só arrasta para a direita inicialmente": começamos no page 0.
    return SizedBox(
      height: height,
      child: PageView.builder(
        controller: _controller,
        padEnds: true,
        pageSnapping: true,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.items.length,
        // renderiza levemente adiante para reduzir “picos”
        allowImplicitScrolling: true,
        itemBuilder: (ctx, index) {
          final data = widget.items[index];
          return RepaintBoundary(
            // ajuda a isolar repaints
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LiveMatchCard(
                league: data.league,
                home: data.home,
                away: data.away,
                score: data.score,
                minuteBadge: data.minuteBadge,
                onDetails: data.onDetails,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiveCardData {
  final String league;
  final String home;
  final String away;
  final String score;
  final String minuteBadge;
  final VoidCallback onDetails;
  LiveCardData({
    required this.league,
    required this.home,
    required this.away,
    required this.score,
    required this.minuteBadge,
    required this.onDetails,
  });
}
