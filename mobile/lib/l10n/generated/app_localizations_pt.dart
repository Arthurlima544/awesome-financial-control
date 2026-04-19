// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AFC — Controle Financeiro';

  @override
  String get genericError => 'Ocorreu um erro inesperado';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get loading => 'Carregando...';

  @override
  String get emptyState => 'Nenhum item encontrado';

  @override
  String get income => 'Receita';

  @override
  String get expense => 'Despesa';

  @override
  String get balance => 'Saldo';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get homeTitle => 'Início';
}
