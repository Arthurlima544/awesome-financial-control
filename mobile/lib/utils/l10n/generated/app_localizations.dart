import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// App title shown in the header
  ///
  /// In pt, this message translates to:
  /// **'AFC — Controle Financeiro'**
  String get appTitle;

  /// Generic fallback error message
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro inesperado'**
  String get genericError;

  /// Retry button label
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// Cancel button label
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Confirm button label
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// Add button label
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// Save button label
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// Delete button label
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// Edit button label
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// Generic loading indicator label
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// Empty list placeholder
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item encontrado'**
  String get emptyState;

  /// Income label
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get income;

  /// Expense label
  ///
  /// In pt, this message translates to:
  /// **'Despesa'**
  String get expense;

  /// Balance label
  ///
  /// In pt, this message translates to:
  /// **'Saldo'**
  String get balance;

  /// Email field label on login screen
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// Password field label on login screen
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// Sign-in button label on login screen
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// Home screen title
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get homeTitle;

  /// Financial summary section title on home screen
  ///
  /// In pt, this message translates to:
  /// **'Resumo do mês'**
  String get homeSummaryTitle;

  /// Total income label on home screen
  ///
  /// In pt, this message translates to:
  /// **'Receitas'**
  String get homeTotalIncome;

  /// Total expenses label on home screen
  ///
  /// In pt, this message translates to:
  /// **'Despesas'**
  String get homeTotalExpenses;

  /// Balance label on home screen
  ///
  /// In pt, this message translates to:
  /// **'Saldo'**
  String get homeBalance;

  /// Recent transactions section title on home screen
  ///
  /// In pt, this message translates to:
  /// **'Últimas transações'**
  String get homeRecentTransactions;

  /// Empty state for transactions list on home screen
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma transação encontrada'**
  String get homeNoTransactions;

  /// Error message when home data fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar dados'**
  String get homeErrorLoading;

  /// No description provided for @homeSavingsRate.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de Poupança'**
  String get homeSavingsRate;

  /// No description provided for @homeViewReport.
  ///
  /// In pt, this message translates to:
  /// **'Ver relatório completo'**
  String get homeViewReport;

  /// No description provided for @homeInsightExcellent.
  ///
  /// In pt, this message translates to:
  /// **'Excelente! Você poupou {rate}% da sua renda este mês.'**
  String homeInsightExcellent(Object rate);

  /// No description provided for @homeInsightGood.
  ///
  /// In pt, this message translates to:
  /// **'Bom trabalho! Você poupou {rate}% este mês.'**
  String homeInsightGood(Object rate);

  /// No description provided for @homeInsightAttention.
  ///
  /// In pt, this message translates to:
  /// **'Atenção! Você poupou apenas {rate}% este mês.'**
  String homeInsightAttention(Object rate);

  /// Spending limits screen title
  ///
  /// In pt, this message translates to:
  /// **'Limites do mês'**
  String get limitTitle;

  /// Empty state for limits list
  ///
  /// In pt, this message translates to:
  /// **'Nenhum limite cadastrado'**
  String get limitNoLimits;

  /// Error message when limits data fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar limites'**
  String get limitErrorLoading;

  /// Amount spent label on limit card
  ///
  /// In pt, this message translates to:
  /// **'Gasto: {amount}'**
  String limitSpent(String amount);

  /// Limit amount label on limit card
  ///
  /// In pt, this message translates to:
  /// **'Limite: {amount}'**
  String limitOf(String amount);

  /// Stats screen title
  ///
  /// In pt, this message translates to:
  /// **'Evolução mensal'**
  String get statsTitle;

  /// Empty state for stats chart
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dado disponível'**
  String get statsNoData;

  /// Error message when stats data fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar estatísticas'**
  String get statsErrorLoading;

  /// No description provided for @statsSummarySavings.
  ///
  /// In pt, this message translates to:
  /// **'Média de Poupança'**
  String get statsSummarySavings;

  /// No description provided for @statsSummaryTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total Acumulado'**
  String get statsSummaryTotal;

  /// No description provided for @statsSummaryBest.
  ///
  /// In pt, this message translates to:
  /// **'Melhor Mês'**
  String get statsSummaryBest;

  /// No description provided for @statsInsightPositiveTrend.
  ///
  /// In pt, this message translates to:
  /// **'Tendência Positiva'**
  String get statsInsightPositiveTrend;

  /// No description provided for @statsInsightNegativeTrend.
  ///
  /// In pt, this message translates to:
  /// **'Atenção aos Gastos'**
  String get statsInsightNegativeTrend;

  /// No description provided for @statsInsightPositiveTrendMsg.
  ///
  /// In pt, this message translates to:
  /// **'Sua taxa de economia está subindo nos últimos meses. Continue assim!'**
  String get statsInsightPositiveTrendMsg;

  /// No description provided for @statsInsightNegativeTrendMsg.
  ///
  /// In pt, this message translates to:
  /// **'Sua taxa de economia caiu recentemente. Revise seus limites de gastos.'**
  String get statsInsightNegativeTrendMsg;

  /// No description provided for @statsInsightBestMonth.
  ///
  /// In pt, this message translates to:
  /// **'Recorde de Economia'**
  String get statsInsightBestMonth;

  /// No description provided for @statsInsightBestMonthMsg.
  ///
  /// In pt, this message translates to:
  /// **'Em {month}, você poupou o máximo do ano!'**
  String statsInsightBestMonthMsg(Object month);

  /// Transaction list screen title
  ///
  /// In pt, this message translates to:
  /// **'Transações'**
  String get transactionListTitle;

  /// Empty state for transaction list screen
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma transação encontrada'**
  String get transactionListEmpty;

  /// Error message when transaction list fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar transações'**
  String get transactionListError;

  /// Title of delete transaction confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Excluir transação'**
  String get transactionDeleteConfirmTitle;

  /// Body of delete transaction confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir esta transação? Esta ação não pode ser desfeita.'**
  String get transactionDeleteConfirmMessage;

  /// No description provided for @transactionListByDate.
  ///
  /// In pt, this message translates to:
  /// **'Por data'**
  String get transactionListByDate;

  /// No description provided for @transactionListByGroup.
  ///
  /// In pt, this message translates to:
  /// **'Por grupo'**
  String get transactionListByGroup;

  /// No description provided for @transactionGroupPix.
  ///
  /// In pt, this message translates to:
  /// **'Transferências PIX'**
  String get transactionGroupPix;

  /// No description provided for @transactionGroupBank.
  ///
  /// In pt, this message translates to:
  /// **'Transferências bancárias'**
  String get transactionGroupBank;

  /// No description provided for @transactionGroupTransport.
  ///
  /// In pt, this message translates to:
  /// **'Transporte por app'**
  String get transactionGroupTransport;

  /// No description provided for @transactionGroupDelivery.
  ///
  /// In pt, this message translates to:
  /// **'Delivery'**
  String get transactionGroupDelivery;

  /// No description provided for @transactionGroupMarket.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get transactionGroupMarket;

  /// No description provided for @transactionGroupSubscription.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas'**
  String get transactionGroupSubscription;

  /// No description provided for @transactionGroupOther.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get transactionGroupOther;

  /// Bottom nav bar home tab label
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// Bottom nav bar transactions tab label
  ///
  /// In pt, this message translates to:
  /// **'Transações'**
  String get navTransactions;

  /// Bottom nav bar limits tab label
  ///
  /// In pt, this message translates to:
  /// **'Limites'**
  String get navLimits;

  /// Bottom nav bar stats tab label
  ///
  /// In pt, this message translates to:
  /// **'Gráficos'**
  String get navStats;

  /// Bottom nav bar planning tab label
  ///
  /// In pt, this message translates to:
  /// **'Planejamento'**
  String get navPlanning;

  /// FAB tooltip for adding a new transaction
  ///
  /// In pt, this message translates to:
  /// **'Adicionar transação'**
  String get fabAddTransaction;

  /// Category list screen title
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get categoryListTitle;

  /// Empty state for category list screen
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma categoria cadastrada'**
  String get categoryListEmpty;

  /// Error message when category list fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar categorias'**
  String get categoryListError;

  /// Title of delete category confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Excluir categoria'**
  String get categoryDeleteConfirmTitle;

  /// Body of delete category confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir esta categoria? Esta ação não pode ser desfeita.'**
  String get categoryDeleteConfirmMessage;

  /// Category edit screen title
  ///
  /// In pt, this message translates to:
  /// **'Editar categoria'**
  String get categoryEditTitle;

  /// Category name field label
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get categoryNameLabel;

  /// Limit list management screen title
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar limites'**
  String get limitListTitle;

  /// Empty state for limit list management screen
  ///
  /// In pt, this message translates to:
  /// **'Nenhum limite cadastrado'**
  String get limitListEmpty;

  /// Error message when limit list fails to load
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar limites'**
  String get limitListError;

  /// Title of delete limit confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Excluir limite'**
  String get limitDeleteConfirmTitle;

  /// Body of delete limit confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir este limite? Esta ação não pode ser desfeita.'**
  String get limitDeleteConfirmMessage;

  /// Limit edit screen title
  ///
  /// In pt, this message translates to:
  /// **'Editar limite'**
  String get limitEditTitle;

  /// Limit amount field label
  ///
  /// In pt, this message translates to:
  /// **'Valor (R\$)'**
  String get limitAmountLabel;

  /// Transaction edit screen title
  ///
  /// In pt, this message translates to:
  /// **'Editar transação'**
  String get transactionEditTitle;

  /// Transaction description field label
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get transactionDescriptionLabel;

  /// Transaction amount field label
  ///
  /// In pt, this message translates to:
  /// **'Valor (R\$)'**
  String get transactionAmountLabel;

  /// Dev tools bottom sheet title
  ///
  /// In pt, this message translates to:
  /// **'Dev Tools'**
  String get devToolsTitle;

  /// Dev seed button label
  ///
  /// In pt, this message translates to:
  /// **'Popular dados'**
  String get devSeedButton;

  /// Dev reset button label
  ///
  /// In pt, this message translates to:
  /// **'Limpar todos os dados'**
  String get devResetButton;

  /// Dev reset onboarding button label
  ///
  /// In pt, this message translates to:
  /// **'Resetar Onboarding'**
  String get devResetOnboardingButton;

  /// Dev seed success snackbar message
  ///
  /// In pt, this message translates to:
  /// **'Dados populados com sucesso'**
  String get devSeedSuccess;

  /// Dev reset success snackbar message
  ///
  /// In pt, this message translates to:
  /// **'Dados removidos com sucesso'**
  String get devResetSuccess;

  /// No description provided for @devResetOnboardingSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Onboarding resetado com sucesso'**
  String get devResetOnboardingSuccess;

  /// Message shown when limits are exceeded on the home dashboard
  ///
  /// In pt, this message translates to:
  /// **'Limite excedido: {limitNames}'**
  String homeLimitExceeded(String limitNames);

  /// Templates section title in quick add
  ///
  /// In pt, this message translates to:
  /// **'Modelos'**
  String get quickAddTemplates;

  /// Supermarket template chip
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get quickAddTemplateSupermarket;

  /// Uber work template chip
  ///
  /// In pt, this message translates to:
  /// **'Uber trabalho'**
  String get quickAddTemplateUberWork;

  /// Category section title in quick add
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get quickAddCategory;

  /// Category: Salary
  ///
  /// In pt, this message translates to:
  /// **'Salário'**
  String get categorySalary;

  /// Category: Transport
  ///
  /// In pt, this message translates to:
  /// **'Transporte'**
  String get categoryTransport;

  /// Category: Investments
  ///
  /// In pt, this message translates to:
  /// **'Investimentos'**
  String get categoryInvestments;

  /// Category: Health
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get categoryHealth;

  /// Category: Food
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get categoryFood;

  /// Category: Housing
  ///
  /// In pt, this message translates to:
  /// **'Moradia'**
  String get categoryHousing;

  /// Category: Leisure
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get categoryLeisure;

  /// Category: Education
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get categoryEducation;

  /// New category chip in quick add
  ///
  /// In pt, this message translates to:
  /// **'+ Nova'**
  String get quickAddCategoryNew;

  /// Title hint in quick add
  ///
  /// In pt, this message translates to:
  /// **'Título (opcional)'**
  String get quickAddTitleHint;

  /// Camera button in quick add
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get quickAddCamera;

  /// Gallery button in quick add
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get quickAddGallery;

  /// Save as template checkbox label
  ///
  /// In pt, this message translates to:
  /// **'Salvar como modelo'**
  String get quickAddSaveTemplate;

  /// Recurring transactions screen title
  ///
  /// In pt, this message translates to:
  /// **'Recorrentes'**
  String get recurringTitle;

  /// Empty state for recurring list
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma regra recorrente cadastrada'**
  String get recurringEmpty;

  /// No description provided for @recurringErrorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar regras recorrentes'**
  String get recurringErrorLoading;

  /// Daily frequency label
  ///
  /// In pt, this message translates to:
  /// **'Diário'**
  String get recurringFrequencyDaily;

  /// Weekly frequency label
  ///
  /// In pt, this message translates to:
  /// **'Semanal'**
  String get recurringFrequencyWeekly;

  /// Monthly frequency label
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get recurringFrequencyMonthly;

  /// Next due date label
  ///
  /// In pt, this message translates to:
  /// **'Próximo vencimento: {date}'**
  String recurringNextDue(String date);

  /// Recurring form title
  ///
  /// In pt, this message translates to:
  /// **'Nova regra recorrente'**
  String get recurringFormTitle;

  /// Frequency field label
  ///
  /// In pt, this message translates to:
  /// **'Frequência'**
  String get recurringFormFrequencyLabel;

  /// Next due field label
  ///
  /// In pt, this message translates to:
  /// **'Primeiro vencimento'**
  String get recurringFormNextDueLabel;

  /// Title of delete recurring confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Excluir regra'**
  String get recurringDeleteConfirmTitle;

  /// Body of delete recurring confirmation dialog
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir esta regra recorrente? Ela deixará de criar novas transações automaticamente.'**
  String get recurringDeleteConfirmMessage;

  /// Import screen title
  ///
  /// In pt, this message translates to:
  /// **'Importar Extrato'**
  String get importTitle;

  /// Label for bank selection in import
  ///
  /// In pt, this message translates to:
  /// **'Banco'**
  String get importBankLabel;

  /// Generic bank option
  ///
  /// In pt, this message translates to:
  /// **'Genérico / Outros'**
  String get importBankGeneric;

  /// Nubank option
  ///
  /// In pt, this message translates to:
  /// **'Nubank'**
  String get importBankNubank;

  /// Label for statement type selection
  ///
  /// In pt, this message translates to:
  /// **'Tipo de extrato'**
  String get importTypeLabel;

  /// OFX type option
  ///
  /// In pt, this message translates to:
  /// **'OFX (Padrão)'**
  String get importTypeOfx;

  /// Extrato type option
  ///
  /// In pt, this message translates to:
  /// **'Extrato Conta Corrente (CSV)'**
  String get importTypeExtrato;

  /// Fatura type option
  ///
  /// In pt, this message translates to:
  /// **'Fatura Cartão de Crédito (CSV)'**
  String get importTypeFatura;

  /// Button to pick file
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Arquivo'**
  String get importPickFile;

  /// Title for review step
  ///
  /// In pt, this message translates to:
  /// **'Revisar transações'**
  String get importReviewTitle;

  /// Submit import button
  ///
  /// In pt, this message translates to:
  /// **'Importar {count} transações'**
  String importSubmit(String count);

  /// Duplicate badge
  ///
  /// In pt, this message translates to:
  /// **'Duplicada'**
  String get importDuplicate;

  /// Success message for import
  ///
  /// In pt, this message translates to:
  /// **'Transações importadas com sucesso!'**
  String get importSuccess;

  /// No description provided for @importConfidenceAuto.
  ///
  /// In pt, this message translates to:
  /// **'Auto'**
  String get importConfidenceAuto;

  /// No description provided for @importConfidenceReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisar'**
  String get importConfidenceReview;

  /// No description provided for @importConfidenceManual.
  ///
  /// In pt, this message translates to:
  /// **'Manual'**
  String get importConfidenceManual;

  /// Report screen title
  ///
  /// In pt, this message translates to:
  /// **'Relatório Mensal'**
  String get reportTitle;

  /// Category spending section title
  ///
  /// In pt, this message translates to:
  /// **'Gastos por Categoria'**
  String get reportCategorySpending;

  /// MoM comparison section title
  ///
  /// In pt, this message translates to:
  /// **'Comparação com Mês Anterior'**
  String get reportMoMComparison;

  /// Savings rate label
  ///
  /// In pt, this message translates to:
  /// **'Economia'**
  String get reportSavingsRate;

  /// Tooltip for full report button
  ///
  /// In pt, this message translates to:
  /// **'Relatório Completo'**
  String get reportFullReport;

  /// Empty state for report
  ///
  /// In pt, this message translates to:
  /// **'Nenhum dado para este mês'**
  String get reportNoData;

  /// Success message for report export
  ///
  /// In pt, this message translates to:
  /// **'Relatório exportado com sucesso'**
  String get reportExportSuccess;

  /// Error message for report export
  ///
  /// In pt, this message translates to:
  /// **'Erro ao exportar relatório'**
  String get reportExportError;

  /// Legend label in report chart
  ///
  /// In pt, this message translates to:
  /// **'Legenda'**
  String get reportLegend;

  /// Bottom nav bar goals tab label
  ///
  /// In pt, this message translates to:
  /// **'Objetivos'**
  String get navGoals;

  /// Savings goals screen title
  ///
  /// In pt, this message translates to:
  /// **'Objetivos de Economia'**
  String get goalsTitle;

  /// Empty state for goals list
  ///
  /// In pt, this message translates to:
  /// **'Nenhum objetivo cadastrado'**
  String get goalsNoGoals;

  /// No description provided for @goalsErrorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar objetivos'**
  String get goalsErrorLoading;

  /// Investments screen title
  ///
  /// In pt, this message translates to:
  /// **'Investimentos'**
  String get investmentsTitle;

  /// Total net worth label (balance + investments)
  ///
  /// In pt, this message translates to:
  /// **'Patrimônio Total'**
  String get totalNetWorth;

  /// Current portfolio value label
  ///
  /// In pt, this message translates to:
  /// **'Valor Atual'**
  String get investmentsCurrentValue;

  /// Total invested amount label
  ///
  /// In pt, this message translates to:
  /// **'Total Investido'**
  String get investmentsTotalInvested;

  /// Empty state for investments list
  ///
  /// In pt, this message translates to:
  /// **'Nenhum investimento cadastrado'**
  String get investmentsNoInvestments;

  /// Label for investment name field
  ///
  /// In pt, this message translates to:
  /// **'Nome do Ativo'**
  String get investmentName;

  /// Label for investment ticker field
  ///
  /// In pt, this message translates to:
  /// **'Símbolo/Ticker'**
  String get investmentTicker;

  /// Label for investment quantity field
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get investmentQuantity;

  /// Label for investment average cost field
  ///
  /// In pt, this message translates to:
  /// **'Custo Médio'**
  String get investmentAvgCost;

  /// Label for investment current price field
  ///
  /// In pt, this message translates to:
  /// **'Preço Atual'**
  String get investmentCurrentPrice;

  /// Label for investment type selector
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Ativo'**
  String get investmentType;

  /// Stock investment type
  ///
  /// In pt, this message translates to:
  /// **'Ação'**
  String get investmentTypeStock;

  /// Fixed income investment type
  ///
  /// In pt, this message translates to:
  /// **'Renda Fixa'**
  String get investmentTypeFixedIncome;

  /// Crypto investment type
  ///
  /// In pt, this message translates to:
  /// **'Cripto'**
  String get investmentTypeCrypto;

  /// Other investment type
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get investmentTypeOther;

  /// Semantics label for stats chart
  ///
  /// In pt, this message translates to:
  /// **'Gráfico de estatísticas mensais'**
  String get statsChartLabel;

  /// Semantics label for reports chart
  ///
  /// In pt, this message translates to:
  /// **'Gráfico de relatórios'**
  String get reportsChartLabel;

  /// Semantics label for progress bar
  ///
  /// In pt, this message translates to:
  /// **'Barra de progresso'**
  String get progressBarLabel;

  /// Semantics label for stepped progress bar
  ///
  /// In pt, this message translates to:
  /// **'Barra de progresso em etapas'**
  String get progressBarSteppedLabel;

  /// Bills screen title
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get billsTitle;

  /// Empty state for bills list
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta cadastrada'**
  String get billsNoBills;

  /// No description provided for @billsErrorLoading.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar contas'**
  String get billsErrorLoading;

  /// Label for bill name field
  ///
  /// In pt, this message translates to:
  /// **'Nome da Conta'**
  String get billName;

  /// Label for bill amount field
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get billAmount;

  /// Label for bill due day field
  ///
  /// In pt, this message translates to:
  /// **'Dia do Vencimento'**
  String get billDueDay;

  /// Upcoming bills status label
  ///
  /// In pt, this message translates to:
  /// **'Próximas'**
  String get billStatusUpcoming;

  /// Overdue bills status label
  ///
  /// In pt, this message translates to:
  /// **'Vencidas'**
  String get billStatusOverdue;

  /// Paid bills status label
  ///
  /// In pt, this message translates to:
  /// **'Pagas'**
  String get billStatusPaid;

  /// Bottom nav bar bills tab label
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get navBills;

  /// Financial health score title
  ///
  /// In pt, this message translates to:
  /// **'Saúde Financeira'**
  String get healthScoreTitle;

  /// Excellent health score status
  ///
  /// In pt, this message translates to:
  /// **'Excelente'**
  String get healthScoreExcellent;

  /// Good health score status
  ///
  /// In pt, this message translates to:
  /// **'Boa'**
  String get healthScoreGood;

  /// Needs attention health score status
  ///
  /// In pt, this message translates to:
  /// **'Atenção'**
  String get healthScoreAttention;

  /// Savings rate score factor
  ///
  /// In pt, this message translates to:
  /// **'Taxa de Poupança'**
  String get healthScoreSavings;

  /// Limit adherence score factor
  ///
  /// In pt, this message translates to:
  /// **'Aderência a Limites'**
  String get healthScoreLimits;

  /// Goal progress score factor
  ///
  /// In pt, this message translates to:
  /// **'Progresso de Objetivos'**
  String get healthScoreGoals;

  /// Expense variance score factor
  ///
  /// In pt, this message translates to:
  /// **'Variância de Gastos'**
  String get healthScoreVariance;

  /// No description provided for @healthScoreTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Sua pontuação baseada nos últimos 30 dias'**
  String get healthScoreTooltip;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao AFC'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Seu controle financeiro pessoal, simples e poderoso.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle seus Gastos'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackDesc.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe cada centavo e defina limites mensais para economizar mais.'**
  String get onboardingTrackDesc;

  /// No description provided for @onboardingInvestTitle.
  ///
  /// In pt, this message translates to:
  /// **'Invista no Futuro'**
  String get onboardingInvestTitle;

  /// No description provided for @onboardingInvestDesc.
  ///
  /// In pt, this message translates to:
  /// **'Monitore seus investimentos e alcance seus objetivos de economia.'**
  String get onboardingInvestDesc;

  /// No description provided for @onboardingHealthTitle.
  ///
  /// In pt, this message translates to:
  /// **'Saúde Financeira'**
  String get onboardingHealthTitle;

  /// No description provided for @onboardingHealthDesc.
  ///
  /// In pt, this message translates to:
  /// **'Veja sua pontuação de saúde financeira e receba insights reais.'**
  String get onboardingHealthDesc;

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onboardingStart;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get settingsProfile;

  /// No description provided for @settingsProfileName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get settingsProfileName;

  /// No description provided for @settingsProfileEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get settingsProfileEmail;

  /// No description provided for @settingsAppearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceTheme.
  ///
  /// In pt, this message translates to:
  /// **'Tema do aplicativo'**
  String get settingsAppearanceTheme;

  /// No description provided for @settingsAppearanceSystem.
  ///
  /// In pt, this message translates to:
  /// **'Padrão do sistema'**
  String get settingsAppearanceSystem;

  /// No description provided for @settingsAppearanceLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get settingsAppearanceLight;

  /// No description provided for @settingsAppearanceDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get settingsAppearanceDark;

  /// No description provided for @settingsNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Notificações push'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsBiometric.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueio biométrico'**
  String get settingsNotificationsBiometric;

  /// No description provided for @settingsData.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get settingsData;

  /// No description provided for @settingsDataExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar todos os dados'**
  String get settingsDataExport;

  /// No description provided for @settingsDataClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar cache local'**
  String get settingsDataClear;

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsAbout;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get settingsAboutVersion;

  /// No description provided for @settingsAboutTerms.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get settingsAboutTerms;

  /// No description provided for @settingsAboutPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get settingsAboutPrivacy;

  /// No description provided for @settingsLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente sair da conta?'**
  String get settingsLogoutConfirm;

  /// No description provided for @privacyMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo Privacidade (Ocultar valores)'**
  String get privacyMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
