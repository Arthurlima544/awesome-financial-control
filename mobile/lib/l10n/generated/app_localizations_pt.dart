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

  @override
  String get homeSummaryTitle => 'Resumo do mês';

  @override
  String get homeTotalIncome => 'Receitas';

  @override
  String get homeTotalExpenses => 'Despesas';

  @override
  String get homeBalance => 'Saldo';

  @override
  String get homeRecentTransactions => 'Últimas transações';

  @override
  String get homeNoTransactions => 'Nenhuma transação encontrada';

  @override
  String get homeErrorLoading => 'Erro ao carregar dados';

  @override
  String get limitTitle => 'Limites do mês';

  @override
  String get limitNoLimits => 'Nenhum limite cadastrado';

  @override
  String get limitErrorLoading => 'Erro ao carregar limites';

  @override
  String limitSpent(String amount) {
    return 'Gasto: $amount';
  }

  @override
  String limitOf(String amount) {
    return 'Limite: $amount';
  }

  @override
  String get statsTitle => 'Evolução mensal';

  @override
  String get statsNoData => 'Nenhum dado disponível';

  @override
  String get statsErrorLoading => 'Erro ao carregar estatísticas';
}
