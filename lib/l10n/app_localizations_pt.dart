// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Hand Scores';

  @override
  String get homeTab => 'Início';

  @override
  String get competitionTab => 'Competições';

  @override
  String get newsTab => 'Notícias';

  @override
  String get accountTab => 'Conta';

  @override
  String get liveNow => 'Ao vivo';

  @override
  String get seeMore => 'Ver mais';

  @override
  String get score => 'Placar';

  @override
  String get details => 'Detalhes';

  @override
  String get ftShort => 'FT';

  @override
  String get premierLeague => 'Premier League';

  @override
  String get nottinghamForest => 'Nottingham Forest';

  @override
  String get manUnited => 'Manchester United';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class SPtBr extends SPt {
  SPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Hand Scores';

  @override
  String get homeTab => 'Início';

  @override
  String get competitionTab => 'Competições';

  @override
  String get newsTab => 'Notícias';

  @override
  String get accountTab => 'Conta';

  @override
  String get liveNow => 'Ao vivo';

  @override
  String get seeMore => 'Ver mais';

  @override
  String get score => 'Placar';

  @override
  String get details => 'Detalhes';

  @override
  String get ftShort => 'FT';

  @override
  String get premierLeague => 'Premier League';

  @override
  String get nottinghamForest => 'Nottingham Forest';

  @override
  String get manUnited => 'Manchester United';
}
