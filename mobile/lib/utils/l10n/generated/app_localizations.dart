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
