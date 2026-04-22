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

  @override
  String get transactionListTitle => 'Transações';

  @override
  String get transactionListEmpty => 'Nenhuma transação encontrada';

  @override
  String get transactionListError => 'Erro ao carregar transações';

  @override
  String get transactionDeleteConfirmTitle => 'Excluir transação';

  @override
  String get transactionDeleteConfirmMessage =>
      'Deseja excluir esta transação? Esta ação não pode ser desfeita.';

  @override
  String get navHome => 'Início';

  @override
  String get navTransactions => 'Transações';

  @override
  String get navLimits => 'Limites';

  @override
  String get navStats => 'Gráficos';

  @override
  String get fabAddTransaction => 'Adicionar transação';

  @override
  String get categoryListTitle => 'Categorias';

  @override
  String get categoryListEmpty => 'Nenhuma categoria cadastrada';

  @override
  String get categoryListError => 'Erro ao carregar categorias';

  @override
  String get categoryDeleteConfirmTitle => 'Excluir categoria';

  @override
  String get categoryDeleteConfirmMessage =>
      'Deseja excluir esta categoria? Esta ação não pode ser desfeita.';

  @override
  String get categoryEditTitle => 'Editar categoria';

  @override
  String get categoryNameLabel => 'Nome';

  @override
  String get limitListTitle => 'Gerenciar limites';

  @override
  String get limitListEmpty => 'Nenhum limite cadastrado';

  @override
  String get limitListError => 'Erro ao carregar limites';

  @override
  String get limitDeleteConfirmTitle => 'Excluir limite';

  @override
  String get limitDeleteConfirmMessage =>
      'Deseja excluir este limite? Esta ação não pode ser desfeita.';

  @override
  String get limitEditTitle => 'Editar limite';

  @override
  String get limitAmountLabel => 'Valor (R\$)';

  @override
  String get transactionEditTitle => 'Editar transação';

  @override
  String get transactionDescriptionLabel => 'Descrição';

  @override
  String get transactionAmountLabel => 'Valor (R\$)';

  @override
  String get devToolsTitle => 'Dev Tools';

  @override
  String get devSeedButton => 'Popular dados';

  @override
  String get devResetButton => 'Limpar todos os dados';

  @override
  String get devSeedSuccess => 'Dados populados com sucesso';

  @override
  String get devResetSuccess => 'Dados removidos com sucesso';

  @override
  String homeLimitExceeded(String limitNames) {
    return 'Limite excedido: $limitNames';
  }

  @override
  String get quickAddTemplates => 'Modelos';

  @override
  String get quickAddTemplateSupermarket => 'Supermercado';

  @override
  String get quickAddTemplateUberWork => 'Uber trabalho';

  @override
  String get quickAddCategory => 'Categoria';

  @override
  String get categorySalary => 'Salário';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryInvestments => 'Investimentos';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryFood => 'Alimentação';

  @override
  String get categoryHousing => 'Moradia';

  @override
  String get categoryLeisure => 'Lazer';

  @override
  String get categoryEducation => 'Educação';

  @override
  String get quickAddCategoryNew => '+ Nova';

  @override
  String get quickAddTitleHint => 'Título (opcional)';

  @override
  String get quickAddCamera => 'Câmera';

  @override
  String get quickAddGallery => 'Galeria';

  @override
  String get quickAddSaveTemplate => 'Salvar como modelo';

  @override
  String get recurringTitle => 'Recorrentes';

  @override
  String get recurringEmpty => 'Nenhuma regra recorrente cadastrada';

  @override
  String get recurringFrequencyDaily => 'Diário';

  @override
  String get recurringFrequencyWeekly => 'Semanal';

  @override
  String get recurringFrequencyMonthly => 'Mensal';

  @override
  String recurringNextDue(String date) {
    return 'Próximo vencimento: $date';
  }

  @override
  String get recurringFormTitle => 'Nova regra recorrente';

  @override
  String get recurringFormFrequencyLabel => 'Frequência';

  @override
  String get recurringFormNextDueLabel => 'Primeiro vencimento';

  @override
  String get recurringDeleteConfirmTitle => 'Excluir regra';

  @override
  String get recurringDeleteConfirmMessage =>
      'Deseja excluir esta regra recorrente? Ela deixará de criar novas transações automaticamente.';

  @override
  String get importTitle => 'Importar Extrato';

  @override
  String get importBankLabel => 'Banco';

  @override
  String get importBankGeneric => 'Genérico / Outros';

  @override
  String get importBankNubank => 'Nubank';

  @override
  String get importTypeLabel => 'Tipo de extrato';

  @override
  String get importTypeOfx => 'OFX (Padrão)';

  @override
  String get importTypeExtrato => 'Extrato Conta Corrente (CSV)';

  @override
  String get importTypeFatura => 'Fatura Cartão de Crédito (CSV)';

  @override
  String get importPickFile => 'Selecionar Arquivo';

  @override
  String get importReviewTitle => 'Revisar transações';

  @override
  String importSubmit(String count) {
    return 'Importar $count transações';
  }

  @override
  String get importDuplicate => 'Duplicada';

  @override
  String get importSuccess => 'Transações importadas com sucesso!';

  @override
  String get reportTitle => 'Relatório Mensal';

  @override
  String get reportCategorySpending => 'Gastos por Categoria';

  @override
  String get reportMoMComparison => 'Comparação com Mês Anterior';

  @override
  String get reportSavingsRate => 'Economia';

  @override
  String get reportFullReport => 'Relatório Completo';

  @override
  String get reportNoData => 'Nenhum dado para este mês';

  @override
  String get reportExportSuccess => 'Relatório exportado com sucesso';

  @override
  String get reportExportError => 'Erro ao exportar relatório';
}
