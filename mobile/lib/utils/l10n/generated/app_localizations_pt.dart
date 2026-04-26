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
  String get add => 'Adicionar';

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
  String get homeSavingsRate => 'Taxa de Poupança';

  @override
  String get homeViewReport => 'Ver relatório completo';

  @override
  String homeInsightExcellent(Object rate) {
    return 'Excelente! Você poupou $rate% da sua renda este mês.';
  }

  @override
  String homeInsightGood(Object rate) {
    return 'Bom trabalho! Você poupou $rate% este mês.';
  }

  @override
  String homeInsightAttention(Object rate) {
    return 'Atenção! Você poupou apenas $rate% este mês.';
  }

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
  String get statsSummarySavings => 'Média de Poupança';

  @override
  String get statsSummaryTotal => 'Total Acumulado';

  @override
  String get statsSummaryBest => 'Melhor Mês';

  @override
  String get statsInsightPositiveTrend => 'Tendência Positiva';

  @override
  String get statsInsightNegativeTrend => 'Atenção aos Gastos';

  @override
  String get statsInsightPositiveTrendMsg =>
      'Sua taxa de economia está subindo nos últimos meses. Continue assim!';

  @override
  String get statsInsightNegativeTrendMsg =>
      'Sua taxa de economia caiu recentemente. Revise seus limites de gastos.';

  @override
  String get statsInsightBestMonth => 'Recorde de Economia';

  @override
  String statsInsightBestMonthMsg(Object month) {
    return 'Em $month, você poupou o máximo do ano!';
  }

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
  String get transactionListByDate => 'Por data';

  @override
  String get transactionListByGroup => 'Por grupo';

  @override
  String get transactionGroupPix => 'Transferências PIX';

  @override
  String get transactionGroupBank => 'Transferências bancárias';

  @override
  String get transactionGroupTransport => 'Transporte por app';

  @override
  String get transactionGroupDelivery => 'Delivery';

  @override
  String get transactionGroupMarket => 'Supermercado';

  @override
  String get transactionGroupSubscription => 'Assinaturas';

  @override
  String get transactionGroupOther => 'Outros';

  @override
  String get navHome => 'Início';

  @override
  String get navTransactions => 'Transações';

  @override
  String get navLimits => 'Limites';

  @override
  String get navStats => 'Gráficos';

  @override
  String get navPlanning => 'Planejamento';

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
  String get devResetOnboardingButton => 'Resetar Onboarding';

  @override
  String get devSeedSuccess => 'Dados populados com sucesso';

  @override
  String get devResetSuccess => 'Dados removidos com sucesso';

  @override
  String get devResetOnboardingSuccess => 'Onboarding resetado com sucesso';

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
  String get recurringErrorLoading => 'Erro ao carregar regras recorrentes';

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
  String get importConfidenceAuto => 'Auto';

  @override
  String get importConfidenceReview => 'Revisar';

  @override
  String get importConfidenceManual => 'Manual';

  @override
  String get feedbackTitle => 'Enviar Feedback';

  @override
  String get feedbackLabel => 'Como está sendo sua experiência com o AFC?';

  @override
  String get feedbackMessageHint => 'Conte-nos mais (opcional)';

  @override
  String get feedbackSubmit => 'Enviar';

  @override
  String get feedbackSuccess => 'Obrigado pelo seu feedback!';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterIncome => 'Receitas';

  @override
  String get filterExpense => 'Despesas';

  @override
  String get filterDate => 'Data';

  @override
  String get filterClear => 'Limpar Filtros';

  @override
  String get transactionSearchHint => 'Buscar transações...';

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

  @override
  String get reportLegend => 'Legenda';

  @override
  String get navGoals => 'Objetivos';

  @override
  String get goalsTitle => 'Objetivos de Economia';

  @override
  String get goalsNoGoals => 'Nenhum objetivo cadastrado';

  @override
  String get goalsErrorLoading => 'Erro ao carregar objetivos';

  @override
  String get investmentsTitle => 'Investimentos';

  @override
  String get totalNetWorth => 'Patrimônio Total';

  @override
  String get investmentsCurrentValue => 'Valor Atual';

  @override
  String get investmentsTotalInvested => 'Total Investido';

  @override
  String get investmentsNoInvestments => 'Nenhum investimento cadastrado';

  @override
  String get tooltipFIRETitle => 'Número FIRE';

  @override
  String get tooltipFIREDesc =>
      'O montante necessário para viver apenas de seus investimentos (Independência Financeira, Aposentadoria Antecipada). Geralmente 25x seus gastos anuais.';

  @override
  String get tooltipFIScoreTitle => 'FI Score';

  @override
  String get tooltipFIScoreDesc =>
      'Mede o quão próximo você está da Independência Financeira. 100% significa que você atingiu seu número FIRE.';

  @override
  String get tooltipSavingsRateTitle => 'Taxa de Poupança';

  @override
  String get tooltipSavingsRateDesc =>
      'A porcentagem de sua renda que sobra após todas as despesas. Quanto maior, mais rápido você atinge a Independência Financeira.';

  @override
  String get tooltipNetWorthTitle => 'Patrimônio Líquido';

  @override
  String get tooltipNetWorthDesc =>
      'A soma de todos os seus ativos (contas, investimentos) menos seus passivos (dívidas). É sua verdadeira riqueza.';

  @override
  String get tooltipCDITitle => 'CDI';

  @override
  String get tooltipCDIDesc =>
      'Certificado de Depósito Interbancário. É a principal taxa de referência para investimentos de renda fixa no Brasil.';

  @override
  String get tooltipSelicTitle => 'Selic';

  @override
  String get tooltipSelicDesc =>
      'A Taxa Selic é a taxa básica de juros da economia brasileira. Ela influencia todas as outras taxas de juros no país.';

  @override
  String get tooltipIPCATitle => 'IPCA';

  @override
  String get tooltipIPCADesc =>
      'O IPCA é o índice oficial de inflação do Brasil. Ele mede a variação de preços para o consumidor final.';

  @override
  String get investmentName => 'Nome do Ativo';

  @override
  String get investmentTicker => 'Símbolo/Ticker';

  @override
  String get investmentQuantity => 'Quantidade';

  @override
  String get investmentAvgCost => 'Custo Médio';

  @override
  String get investmentCurrentPrice => 'Preço Atual';

  @override
  String get investmentType => 'Tipo de Ativo';

  @override
  String get investmentTypeStock => 'Ação';

  @override
  String get investmentTypeFixedIncome => 'Renda Fixa';

  @override
  String get investmentTypeCrypto => 'Cripto';

  @override
  String get investmentTypeOther => 'Outro';

  @override
  String get statsChartLabel => 'Gráfico de estatísticas mensais';

  @override
  String get reportsChartLabel => 'Gráfico de relatórios';

  @override
  String get progressBarLabel => 'Barra de progresso';

  @override
  String get progressBarSteppedLabel => 'Barra de progresso em etapas';

  @override
  String get billsTitle => 'Contas';

  @override
  String get billsNoBills => 'Nenhuma conta cadastrada';

  @override
  String get billsErrorLoading => 'Erro ao carregar contas';

  @override
  String get billName => 'Nome da Conta';

  @override
  String get billAmount => 'Valor';

  @override
  String get billDueDay => 'Dia do Vencimento';

  @override
  String get billStatusUpcoming => 'Próximas';

  @override
  String get billStatusOverdue => 'Vencidas';

  @override
  String get billStatusPaid => 'Pagas';

  @override
  String get navBills => 'Contas';

  @override
  String get healthScoreTitle => 'Saúde Financeira';

  @override
  String get healthScoreExcellent => 'Excelente';

  @override
  String get healthScoreGood => 'Boa';

  @override
  String get healthScoreAttention => 'Atenção';

  @override
  String get healthScoreSavings => 'Taxa de Poupança';

  @override
  String get healthScoreLimits => 'Aderência a Limites';

  @override
  String get healthScoreGoals => 'Progresso de Objetivos';

  @override
  String get healthScoreVariance => 'Variância de Gastos';

  @override
  String get healthScoreTooltip => 'Sua pontuação baseada nos últimos 30 dias';

  @override
  String get onboardingWelcomeTitle => 'Bem-vindo ao AFC';

  @override
  String get onboardingWelcomeDesc =>
      'Seu controle financeiro pessoal, simples e poderoso.';

  @override
  String get onboardingTrackTitle => 'Controle seus Gastos';

  @override
  String get onboardingTrackDesc =>
      'Acompanhe cada centavo e defina limites mensais para economizar mais.';

  @override
  String get onboardingInvestTitle => 'Invista no Futuro';

  @override
  String get onboardingInvestDesc =>
      'Monitore seus investimentos e alcance seus objetivos de economia.';

  @override
  String get onboardingHealthTitle => 'Saúde Financeira';

  @override
  String get onboardingHealthDesc =>
      'Veja sua pontuação de saúde financeira e receba insights reais.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsProfileName => 'Nome completo';

  @override
  String get settingsProfileEmail => 'E-mail';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsAppearanceTheme => 'Tema do aplicativo';

  @override
  String get settingsAppearanceSystem => 'Padrão do sistema';

  @override
  String get settingsAppearanceLight => 'Claro';

  @override
  String get settingsAppearanceDark => 'Escuro';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsEnabled => 'Notificações push';

  @override
  String get settingsNotificationsBiometric => 'Bloqueio biométrico';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsDataExport => 'Exportar todos os dados';

  @override
  String get settingsDataClear => 'Limpar cache local';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutVersion => 'Versão';

  @override
  String get settingsAboutTerms => 'Termos de uso';

  @override
  String get settingsAboutPrivacy => 'Política de privacidade';

  @override
  String get settingsLogout => 'Sair da conta';

  @override
  String get settingsLogoutConfirm => 'Deseja realmente sair da conta?';

  @override
  String get privacyMode => 'Modo Privacidade (Ocultar valores)';

  @override
  String get calcResultTitle => 'Resultado';

  @override
  String get calcInflationToggleLabel => 'Ajuste de Inflação';

  @override
  String get calcInflationToggleSubtitle =>
      'Valores em poder de compra de hoje';

  @override
  String get calcChartTodayLabel => 'Hoje';

  @override
  String calcChartYearLabel(int n) {
    return 'A$n';
  }

  @override
  String get calcButtonCalcular => 'Calcular';

  @override
  String get calcButtonEntendi => 'Entendi';

  @override
  String calcErrorMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get calcPatrimonioEvolutionTitle => 'Evolução do Patrimônio';

  @override
  String get calcRentabilidadeTooltipTitle => 'Rentabilidade';

  @override
  String get calcCapitalInicialTooltipTitle => 'Capital Inicial';

  @override
  String get fireCalcTitle => 'Calculadora FIRE';

  @override
  String get fireCalcExpensesLabel => 'Gastos mensais (R\$)';

  @override
  String get fireCalcExpensesTooltipTitle => 'Gastos Mensais';

  @override
  String get fireCalcExpensesTooltipDesc =>
      'O custo total para manter seu padrão de vida atual. Quanto mais baixo, menor será seu Número FIRE.';

  @override
  String get fireCalcSavingsLabel => 'Investimento mensal (R\$)';

  @override
  String get fireCalcSavingsTooltipTitle => 'Aporte Mensal';

  @override
  String get fireCalcSavingsTooltipDesc =>
      'Quanto você economiza e investe todos os meses. Este é o motor que acelera sua independência financeira.';

  @override
  String get fireCalcPortfolioLabel => 'Patrimônio atual (R\$)';

  @override
  String get fireCalcPortfolioTooltipTitle => 'Patrimônio';

  @override
  String get fireCalcPortfolioTooltipDesc =>
      'A soma de todos os seus investimentos atuais e saldo em conta.';

  @override
  String get fireCalcReturnLabel => 'Retorno anual esperado (%)';

  @override
  String get fireCalcReturnTooltipDesc =>
      'A rentabilidade média estimada dos seus investimentos. Um valor conservador costuma ser entre 4% e 7% ao ano acima da inflação.';

  @override
  String get fireCalcSwrLabel => 'Taxa de Retirada (SWR)';

  @override
  String get fireCalcSwrLeanChip => 'Lean FIRE (3%)';

  @override
  String get fireCalcSwrStandardChip => 'Padrão (4%)';

  @override
  String get fireCalcSwrFatChip => 'Fat FIRE (5%)';

  @override
  String get fireCalcFireNumberLabel => 'Número FIRE';

  @override
  String get fireCalcTimeToFireLabel => 'Tempo até FIRE';

  @override
  String fireCalcTimeToFireValue(int years, int months) {
    return '$years anos e $months meses';
  }

  @override
  String get fireCalcEstimatedDateLabel => 'Data estimada';

  @override
  String get fireCalcChartTitle => 'Trajetória do Portfólio';

  @override
  String fireCalcChartProjectionLabel(int year) {
    return 'Projeção até $year';
  }

  @override
  String fireCalcChartSwrLabel(int rate) {
    return 'Taxa de retirada segura: $rate% a.a.';
  }

  @override
  String get fireCalcAboutCardTitle => 'O que é o Movimento FIRE?';

  @override
  String get fireCalcAboutCardDesc =>
      'Financial Independence, Retire Early (Independência Financeira, Aposentadoria Precoce). O objetivo é acumular patrimônio suficiente para viver apenas dos rendimentos de seus investimentos.';

  @override
  String get fireCalcAboutCardButton => 'Saber mais';

  @override
  String get fireCalcSheetTitle => 'Conceitos do FIRE';

  @override
  String get fireCalcSheetFireNumberTitle => 'Número FIRE';

  @override
  String get fireCalcSheetFireNumberDesc =>
      'É o valor total que você precisa ter investido para se aposentar. Geralmente calculado como 25x seus gastos anuais.';

  @override
  String get fireCalcSheetSwrTitle => 'Regra dos 4% (SWR)';

  @override
  String get fireCalcSheetSwrDesc =>
      'Safe Withdrawal Rate (Taxa de Retirada Segura). É a porcentagem do seu patrimônio que você pode sacar anualmente sem que o dinheiro acabe.';

  @override
  String get fireCalcSheetLeanTitle => 'Lean FIRE';

  @override
  String get fireCalcSheetLeanDesc =>
      'Foco em uma vida minimalista e gastos extremamente baixos para se aposentar mais rápido.';

  @override
  String get fireCalcSheetFatTitle => 'Fat FIRE';

  @override
  String get fireCalcSheetFatDesc =>
      'Foco em manter um padrão de vida alto, exigindo um patrimônio muito maior.';

  @override
  String get compoundCalcTitle => 'Simulador de Juros Compostos';

  @override
  String get compoundCalcInitialLabel => 'Investimento Inicial (R\$)';

  @override
  String get compoundCalcInitialTooltipDesc =>
      'O valor que você já tem hoje para começar a investir.';

  @override
  String get compoundCalcContributionLabel => 'Aporte Mensal (R\$)';

  @override
  String get compoundCalcContributionTooltipTitle => 'Investimento Mensal';

  @override
  String get compoundCalcContributionTooltipDesc =>
      'Quanto você planeja investir todos os meses.';

  @override
  String get compoundCalcPeriodLabel => 'Período (Anos)';

  @override
  String get compoundCalcPeriodTooltipTitle => 'Tempo';

  @override
  String get compoundCalcPeriodTooltipDesc =>
      'Por quanto tempo você pretende manter o investimento.';

  @override
  String get compoundCalcRateLabel => 'Taxa Anual (%)';

  @override
  String get compoundCalcRateTooltipDesc => 'A taxa de juros anual estimada.';

  @override
  String get compoundCalcButtonSimular => 'Simular';

  @override
  String get compoundCalcFinalAmountLabel => 'Valor Final';

  @override
  String get compoundCalcTotalInvestedLabel => 'Total Investido';

  @override
  String get compoundCalcTotalInterestLabel => 'Total em Juros';

  @override
  String get compoundCalcLegendAccumulated => 'Acumulado';

  @override
  String get compoundCalcLegendInvested => 'Investido';

  @override
  String get investmentGoalCalcTitle => 'Meta de Investimento';

  @override
  String get investmentGoalCalcTargetLabel => 'Quanto você quer ter? (R\$)';

  @override
  String get investmentGoalCalcTargetTooltipTitle => 'Objetivo';

  @override
  String get investmentGoalCalcTargetTooltipDesc =>
      'O valor total que você deseja acumular até a data alvo.';

  @override
  String get investmentGoalCalcDateLabel => 'Data alvo';

  @override
  String get investmentGoalCalcDateTooltipTitle => 'Prazo';

  @override
  String get investmentGoalCalcDateTooltipDesc =>
      'A data em que você pretende atingir seu objetivo.';

  @override
  String get investmentGoalCalcInitialLabel => 'Quanto você já tem? (R\$)';

  @override
  String get investmentGoalCalcInitialTooltipDesc =>
      'O valor que você já possui investido para este objetivo.';

  @override
  String get investmentGoalCalcReturnLabel => 'Retorno anual esperado (%)';

  @override
  String get investmentGoalCalcReturnTooltipDesc =>
      'A rentabilidade média estimada dos seus investimentos.';

  @override
  String get investmentGoalCalcMonthlyContributionLabel =>
      'Aporte Mensal Necessário';

  @override
  String get investmentGoalCalcTotalContributedLabel =>
      'Total que você investirá';

  @override
  String get investmentGoalCalcTotalInterestLabel => 'Total em juros ganhos';

  @override
  String get investmentGoalCalcCompositionBarTitle =>
      'Composição do valor final';

  @override
  String get investmentGoalCalcLegendContributions => 'Aportes';

  @override
  String get investmentGoalCalcLegendInterest => 'Juros';

  @override
  String get investmentGoalCalcInfoCardTitle => 'Planejando seu futuro';

  @override
  String get investmentGoalCalcInfoCardDesc =>
      'Definir metas claras é o primeiro passo para o sucesso financeiro. Lembre-se que aportes constantes são mais importantes que a rentabilidade a longo prazo.';

  @override
  String get screenNoDataAvailable => 'Nenhum dado disponível';

  @override
  String get investmentDashboardTitle => 'Análise do Portfólio';

  @override
  String get investmentDashboardProfitLossLabel => 'Lucro/Prejuízo';

  @override
  String get investmentDashboardAllocationTitle => 'Alocação de Ativos';

  @override
  String get investmentDashboardPerformanceTitle => 'Performance por Ativo';

  @override
  String get marketScreenTitle => 'Oportunidades de Mercado';

  @override
  String marketLastUpdated(String date) {
    return 'Última atualização: $date';
  }

  @override
  String get marketBenchmarksTitle => 'Benchmarks Fixos';

  @override
  String get marketFilterAll => 'Todos';

  @override
  String get marketFilterStocks => 'Ações';

  @override
  String get marketFilterFiis => 'FIIs';

  @override
  String get marketSortHighestDy => 'Maior DY';

  @override
  String get marketSortDyVsCdi => 'DY vs CDI';

  @override
  String get marketSortLowestPe => 'Menor P/L';

  @override
  String get marketDyColumnHeader => 'DY (ano)';

  @override
  String marketDyVsCdiPercent(int percent) {
    return '$percent% do CDI';
  }

  @override
  String get passiveIncomeTitle => 'Renda Passiva';

  @override
  String get passiveIncomeFreedomIndexTitle => 'Índice de Liberdade Financeira';

  @override
  String get passiveIncomeFreedomIndexGoal => 'da meta mensal';

  @override
  String passiveIncomeReceivedThisMonth(String amount) {
    return 'Recebido este mês: $amount';
  }

  @override
  String get passiveIncomeGoalCovered =>
      '🎉 Suas despesas fixas estão cobertas!';

  @override
  String get passiveIncomeMonthlyEvolutionTitle => 'Evolução Mensal';

  @override
  String get passiveIncomeSourcesTitle => 'Fontes de Renda';

  @override
  String get netWorthNetWorthLabel => 'Patrimônio Líquido Atual';

  @override
  String get netWorthAssetsLabel => 'Ativos';

  @override
  String get netWorthLiabilitiesLabel => 'Passivos';

  @override
  String get netWorthMonthlyHistoryTitle => 'Histórico Mensal';

  @override
  String netWorthAssetsSubtitle(String amount) {
    return '$amount em ativos';
  }

  @override
  String get planningCalculators => 'Calculadoras';

  @override
  String get goalContributionDialogTitle => 'Adicionar Contribuição';

  @override
  String get goalContributionValueLabel => 'Valor';

  @override
  String get goalContributionTooltip => 'Adicionar contribuição';

  @override
  String get goalDeleteTooltip => 'Excluir objetivo';

  @override
  String goalDaysRemaining(int days) {
    return '$days dias restantes';
  }

  @override
  String goalDeadlineUntil(String date) {
    return 'Até $date';
  }

  @override
  String get goalDeleteConfirmTitle => 'Excluir Objetivo';

  @override
  String goalDeleteConfirmMessage(String name) {
    return 'Deseja realmente excluir o objetivo \"$name\"?';
  }

  @override
  String goalTargetAmountLabel(String amount) {
    return 'Meta: $amount';
  }

  @override
  String get recurringPaidBadge => 'Pago';

  @override
  String get reportNoExpenses => 'Sem gastos';

  @override
  String get reportNoDataSimple => 'Sem dados';

  @override
  String get quickAddAnalyzingReceipt => 'Analisando recibo...';

  @override
  String healthScoreSubScorePattern(int value) {
    return '$value/25';
  }

  @override
  String get goalFormNameHint => 'Nome do objetivo';

  @override
  String get goalFormTargetHint => 'Valor total (R\$)';

  @override
  String get goalFormDeadlineLabel => 'Prazo final';

  @override
  String importErrorTitle(String error) {
    return 'Erro: $error';
  }

  @override
  String get settingsCurrencyTitle => 'Moeda de exibição';
}
