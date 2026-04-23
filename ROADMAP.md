# AFC — Product Roadmap

## Objective

Build a complete personal finance management app where users can:
- Authenticate securely
- Track income and expenses with custom categories
- Set and monitor monthly spending limits with overspend alerts
- View real-time financial trends through charts and summaries
- Import bank statements, and auto-sync transactions
- Track savings goals, investments, bill reminders, and a financial health score

The project is **multi-platform** — it must work on **web and mobile via Flutter**.

---

## Technical Standards & Architecture

These rules govern all development on this project. Every PR must comply with them.

### Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (web + mobile) |
| Backend | Spring Boot |
| Database | PostgreSQL 16 |
| ORM | JPA |
| Backend entity pattern | Builder with records |
| Migrations | Flyway |
| API documentation | Swagger / OpenAPI |
| Exception handling | GlobalExceptionHandler |
| Internationalisation | i18n — pt-BR only (for now) |

### Project Structure

**Backend** must follow:
```
Repository → Service → Controller → Model → DTO → Mapper → Config
```

**Mobile** must follow the official Flutter MVVM architecture:
```
View → ViewModel → Repository → Service
```
Reference: https://docs.flutter.dev/app-architecture/guide

No business logic in Views. All operations must be delegated to ViewModels.

### Mobile Design Constants

General config files must exist across the project: `AppSpacing`, `AppColors`, `AppTextStyles`, etc.
All strings must be stored in i18n (pt-BR).

### Environment Variables

- Never add variables directly to `application.properties`. All secrets and config must be injected via environment variables.
- Committing `.env` files is **prohibited**. A pre-commit hook must block `.env` commits.

### Commit Standard — Conventional Commits

Format: `(US-N) @username type: description`

Reference: https://www.conventionalcommits.org/en/v1.0.0/

```
(US-1)  @Arthurlima544 feat: add user authentication
(US-2)  @Arthurlima544 fix: correct login bug
(US-3)  @Arthurlima544 docs: update README with setup instructions
(US-4)  @Arthurlima544 refactor: improve code structure in user service
(US-5)  @Arthurlima544 test: add unit tests for authentication
(US-6)  @Arthurlima544 chore: update dependencies
```

### Branch Strategy

Every branch must be created from `main`, ensuring code is always up-to-date and avoiding merge conflicts.

### Code Quality

- Linters and automatic formatters must be configured for both backend and mobile.
- A **pre-push hook** must ensure the code is error-free before pushing:
  ```
  # .git/hooks/pre-push
  flutter build ios --no-codesign --debug
  ```
- Code with **critical security issues** identified by SonarQube must be corrected immediately and must never be pushed to the repository under any circumstances.

### Testing Standards

- **Backend**: BDD pattern using **Cucumber** and **TestContainers**.
- **Mobile**: BDD pattern using **flutter test**.
- All components must be tested. No exceptions.

---

## Sprint 0 — Foundation & Day One

> **Goal**: Establish "Day One" — the project must be deployable to the staging environment with all quality and security configurations in place before any feature work begins.

### US-S0-01 · Repository & environment separation ✅
- [x] Create `local`, `staging`, and `prod` environment configurations
- [x] Backend: environment-specific `application-{env}.properties` fed entirely by ENV variables
- [x] Mobile: environment-specific `AppConfig` class (local / staging / prod flavors)
- [x] `.env` added to `.gitignore`; pre-commit hook blocks any `.env` commits

### US-S0-02 · Containerisation ✅
- [x] `Dockerfile` for the backend (multi-stage build)
- [x] `docker-compose.yml` with services: `api`, `postgres` (16)
- [x] `docker-compose.staging.yml` override for staging deployment
- [x] Local dev environment runs entirely via Docker Compose

### US-S0-03 · Database setup — PostgreSQL 16 & Flyway ✅
- [x] PostgreSQL 16 container configured
- [x] Flyway dependency added to `pom.xml`
- [x] Flyway migrations directory with `V1__init.sql` baseline
- [x] Spring Boot runs migrations automatically on startup
- [ ] Migration validated in CI (pending CI setup in US-S0-08)

### US-S0-04 · Backend project scaffold ✅
- [x] Spring Boot dependencies configured: Web, JPA, Actuator, Validation, Springdoc, Lombok, Cucumber, TestContainers
- [x] Package structure created: `controller`, `service`, `repository`, `model`, `dto`, `mapper`, `config`, `exception`
- [x] `GlobalExceptionHandler` with standard error response shape
- [x] Swagger / OpenAPI configured and available at `/swagger-ui.html`
- [x] JPA entities using the Builder pattern with records
- [x] Health-check endpoint `GET /actuator/health` (via spring-boot-starter-actuator)

### US-S0-05 · Mobile project scaffold — MVVM + design system ✅
- [x] Flutter project with folder structure: `features/`, `config/`, shared components
- [x] `AppColors`, `AppTextStyles`, `AppSpacing` constants files
- [x] i18n configured with a `pt-BR` ARB file; all strings externalised
- [x] Linter (`analysis_options.yaml`) and formatter configured

### US-S0-06 · Code quality tooling ✅
- [x] Backend: Spotless configured with Google Java Format; CI fails on style violations
- [x] Mobile: `flutter analyze` and `dart format --set-exit-if-changed` in CI
- [x] Pre-push hook configured running `flutter build ios --no-codesign --debug`
- [x] commit-msg hook validates Conventional Commits format on every local commit

### US-S0-07 · SonarQube quality gate ✅
- [x] SonarQube project configured for backend (`sonar.*` properties in `pom.xml`)
- [x] SonarQube project configured for mobile (`sonar-project.properties`)
- [x] GitHub Actions integration: analysis runs on every PR targeting `main`
- [ ] Branch protection rules configured in GitHub (manual step — repo settings)
- [x] Critical security findings must be resolved before merge — no exceptions

### US-S0-08 · CI/CD — GitHub Actions ✅
- [x] Mobile pipeline: lint → format check → test → build web
- [x] Backend pipeline: spotless → test → build → SonarQube analysis
- [x] Deploy to staging on merge to `main` (pending staging server setup)
- [x] Pipeline status badge added to README (pending first successful run)

### US-S0-09 · Commit & branch enforcement ✅
- [x] Conventional Commits format validated via `commit-msg` git hook
- [x] Branch protection rules on `main`: require PR and passing CI (manual step — GitHub settings)
- [x] All branches must be created from `main` (enforced by convention)

---

## Sprint 1 — Auth Flow & Real Dashboard Data

### US-S1-01 · JaCoCo coverage for SonarQube quality gate ✅
**As a** developer, **I want** test coverage to be reported to SonarQube automatically,
**so that** the ≥ 80% coverage quality gate is enforced on every PR.

- JaCoCo Maven plugin added: `prepare-agent` + `report` executions bound to the `test` phase
- `sonar.coverage.jacoco.xmlReportPaths` set to `target/site/jacoco/jacoco.xml`
- CI `Test & Coverage` step runs `mvnw test jacoco:report` before Sonar analysis

---

### US-S1-00 · Fix Android startup crash ✅
**As a** user, **I want** the app to open without crashing on Android,
**so that** I can actually use it.

- Root cause: `MainActivity.kt` declared `package com.example.afc` but the Android namespace is `com.awesome.financial.control.afc`
- Fix: moved `MainActivity.kt` to the correct directory and updated the package declaration
- No tests required (build-level fix verified by successful APK build)

---

### US-01 · Real financial summary on dashboard ✅
**As a** user, **I want** to see my real total income, total expenses, and balance on the home page,
**so that** I have an accurate snapshot of my finances.

- `HomeBloc` loads the financial summary via `HomeRepository` (`GET /api/v1/summary`)
- Computes `totalIncome`, `totalExpenses`, `balance` for the current month (backend)
- `HomeScreen` displays real values with a summary card (replacing empty state)
- 6 `blocTest` unit tests for `HomeBloc` summary loading

---

### US-02 · Real last transactions on dashboard ✅
**As a** user, **I want** to see my most recent transactions on the home page,
**so that** I can quickly review recent activity without opening the full list.

- `HomeBloc` loads last 5 transactions via `HomeRepository` (`GET /api/v1/transactions?limit=N`)
- `HomeScreen` renders the transaction list with income/expense icons (replacing empty state)
- Both summary and transactions fetched in parallel via `Future.wait`
- BDD Cucumber + TestContainers scenarios for backend endpoints

---

### US-05 · Auto-redirect on app launch ✅
**As a** user, **I want** the app to automatically send me to the right screen on launch based on my auth state,
**so that** I don't have to manually navigate after opening the app.

- `SplashScreen` dispatches `AppLaunched` to `AuthBloc`; shows `CircularProgressIndicator`
- go_router `redirect` drives routes: `AuthInitial → /`, `AuthSignedOut → /login`, `AuthSignedIn → /home`
- 5 `blocTest` unit tests for `AuthBloc`

---

### US-06 · Auto-redirect after sign-in ✅
**As a** user, **I want** the app to automatically navigate me to the home page after I sign in,
**so that** I don't have to tap anything extra after authenticating.

- `LoginScreen` dispatches `SignInSubmitted` to `AuthBloc`; go_router redirects to `/home` on `AuthSignedIn`
- Uses `AdaptiveTextField` + `AdaptiveButton` shared components
- `LoginFormCubit` manages email, password, and password visibility state

---

## Sprint 2 — Limits & Charts

### US-03 · Spending limits progress
**As a** user, **I want** to see how much of my monthly limit I've used per category,
**so that** I know when I'm approaching or exceeding my budget.

- `LimitViewModel.loadLimitsWithProgress` fetches from `GET /limits/progress` (limits, categories, and transaction totals for current month)
- Computes `spent` per category for the current month (expense transactions only)
- `MonthLimitView` displays real progress bars per category
- Unit tests (6)

---

### US-04 · Real chart data
**As a** user, **I want** the financial charts to reflect my actual transaction history,
**so that** I can see real spending trends over time.

- `StatsView` reads from `StatsViewModel` which calls `GET /stats/monthly`
- Income/expense series converted to chart data points
- Dynamic y-axis interval based on max data value
- Aggregation logic covered by unit tests

---

## Sprint 3 — CRUD Lists ✅

### US-07 · Transaction list screen ✅
- Screen listing all transactions for the current user
- Fetches from `GET /transactions` via `TransactionListBloc` → `TransactionListRepository`
- `blocTest` unit tests for fetch, empty, error states

### US-08 · Delete transaction ✅
- Swipe-to-delete with `AdaptivePopup` confirmation on transaction list
- Calls `DELETE /transactions/{id}`; optimistic removal from list
- `blocTest` unit tests for delete success and failure

### US-09 · Category list screen ✅
- Screen listing all categories with `CustomListTile` + swipe-to-delete
- Fetches from `GET /categories` via `CategoryBloc` → `CategoryRepository`
- `blocTest` unit tests for fetch, delete, update

### US-10 · Delete category ✅
- Swipe-to-delete with `AdaptivePopup` confirmation on category list
- Calls `DELETE /categories/{id}`; optimistic removal from list
- Covered by `CategoryBloc` tests

### US-11 · Limit list screen ✅
- Screen listing all limits with `CustomListTile` + swipe-to-delete
- Fetches from `GET /limits` via `LimitListBloc` → `LimitListRepository`
- `blocTest` unit tests for fetch, delete, update

### US-12 · Delete limit ✅
- Swipe-to-delete with `AdaptivePopup` confirmation on limit list
- Calls `DELETE /limits/{id}`; optimistic removal from list
- Covered by `LimitListBloc` tests

### US-13 · Edit transaction / category / limit ✅
- Pre-filled edit forms for all three resources; navigated via `context.push` with bloc passed as `extra`
- Calls `PUT /transactions/{id}` / `PUT /categories/{id}` / `PUT /limits/{id}`; optimistic list update
- `blocTest` unit tests for update success and failure on all three blocs

---

## Sprint 4 — UI/UX Overhaul & Reactivity

### US-DEV-01 · Dev data seeder (local only) ✅
**As a** developer, **I want** a quick way to populate and clear sample data while running locally,
**so that** I can test the app with realistic data without manually creating records.

- Backend: `DevSeedController` active only on `local` Spring profile
  - `POST /api/v1/dev/seed` → seeds 6 categories, 3 limits, 10 transactions (current + previous month); returns 201
  - `DELETE /api/v1/dev/reset` → deletes all transactions, limits, categories; returns 204
- Mobile: dev button visible in home `AppBar` only when `AppConfig.isLocal`
  - Opens a bottom sheet with "Populate data" and "Clear data" actions
  - Shows loading state during request; snackbar on success/error
- BDD scenarios for seed and reset endpoints

> **Goal**: Make the app feel polished, responsive, and snappy. Fix the biggest pain points before adding new features.

### US-14 · Real-time dashboard reactivity
**As a** user, **I want** the home page to automatically reflect new/edited/deleted data without manual refresh,
**so that** I always see accurate numbers after any change.

- Dashboard refreshes after any mutation (transactions, limits)
- List screens also update after any write operation
- Unit tests updated accordingly

---

### US-15 · Bottom navigation bar ✅
**As a** user, **I want** persistent bottom navigation between the main sections of the app,
**so that** I can switch between Dashboard, Transactions, Categories, and Limits in one tap.

- `ScaffoldShell` with `StatefulShellRoute` (GoRouter) wrapping the six main screens
- Active tab highlighted; GoRouter state preserved per tab
- Replace scattered "Ver Todas" buttons with navigation-bar equivalent routes
- Widget tests for tab switching (6 tests — renders, labels, FAB, initial index, tap index 1, tap index 5)

---

### US-16 · Quick-add transaction FAB ✅
**As a** user, **I want** to add a transaction from anywhere in the app with as few taps as possible,
**so that** I can record spending the moment it happens without navigating through menus.

- Floating Action Button visible on all main-section screens
- Bottom sheet modal with: amount numpad, income/expense toggle, category picker, optional title
- Saves transaction and dismisses — no full-screen navigation required
- Haptic feedback on save

---

### US-17 · Design system refresh ✅
**As a** user, **I want** a clean, consistent visual design,
**so that** the app feels professional and easy to navigate.

- Define and apply a consistent colour palette (primary, surface, error, success) via `ThemeData`
- Replace all ad-hoc `TextStyle` calls with named theme text styles
- Standardise spacing via `AppSpacing`
- Add empty-state illustrations for lists with no data
- Improve form screens: inline validation messages, better date/month pickers
- Add loading skeletons (shimmer) instead of bare `CircularProgressIndicator`

---

### US-18 · Limit overspend alert ✅
**As a** user, **I want** a visual warning when I exceed a spending limit,
**so that** I can take action before going further over budget.

- `MonthLimitView` displays a red badge and warning text when `spent > limitAmount`
- In-app toast/snackbar on home page when any limit is exceeded
- Unit tests for overspend detection logic

### US-32 · Sync status indicator on dashboard
**As a** user, **I want** to see at a glance when my accounts were last synced and whether any need attention,
**so that** I know my data is fresh without opening the connected accounts screen.

- Small "Last synced X minutes ago" label on the dashboard header when at least one account is connected
- Warning chip (yellow) when any account has `status = consent_expired`
- Error chip (red) when sync failed; tapping navigates to `ConnectedAccountsScreen`

---

## Sprint 6 — Smart Transactions & Recurring Expenses

> **Goal**: Reduce the remaining manual effort for users who want to supplement it.

### US-19 · Recurring transactions [COMPLETED]
**As a** user, **I want** to mark a transaction as recurring (daily / weekly / monthly),
**so that** predictable expenses like rent and subscriptions are logged automatically.

- [x] Backend: `RecurringEntity` — `uuid`, `userId`, `templateTransaction`, `frequency` (daily/weekly/monthly), `nextDue`, `active`; full CRUD endpoints
- [x] `RecurringViewModel` — create, list, pause, delete recurring rules
- [x] On-app-open check materialises due transactions via backend scheduled job
- [x] List screen with toggle to pause/resume each rule
- [x] Unit tests for due-date calculation logic

---

### US-20 · Transaction templates (quick-fill)
**As a** user, **I want** to save frequently used transactions as templates,
**so that** I can log a repeat expense (e.g. "Coffee R$8") in two taps.

- "Save as template" option on the transaction form
- Templates shelf in the quick-add FAB modal (horizontal scroll)
- Tapping a template pre-fills the form; user only confirms amount if needed
- Unit tests for template storage and retrieval

---

### US-21 · Bank statement import (OFX / CSV) [COMPLETED]
**As a** user, **I want** to import my bank statement file,
**so that** I don't have to manually enter transactions I've already made.

- [x] File picker accepting `.ofx` and `.csv` formats
- [x] Parser maps statement rows → transaction candidates
- [x] Review screen: user confirms, rejects, or re-categorises each import row before saving
- [x] Duplicate detection (same date + amount + description → skip or warn)
- [x] Unit tests for OFX and CSV parsing logic

---

### US-21b · Bank-specific import profiles [COMPLETED]
**As a** user, **I want** to select my bank and statement type before importing,
**so that** the app parses my file correctly regardless of each bank's proprietary format.

- [x] Bank selector + statement type selector shown before file picker (bank: Nubank; type: Extrato or Fatura)
- [x] `parseNubankExtrato` — columns `Data/Valor/Descrição`, DD/MM/YYYY, standard polarity
- [x] `parseNubankFatura` — columns `date/title/amount`, ISO date, inverted polarity (positive = expense), quoted-field support
- [x] Unit tests for both Nubank parsers with real-format sample data

---

### US-22 · Receipt photo & auto-fill [COMPLETED]
**As a** user, **I want** to photograph a receipt and have the amount and merchant pre-filled,
**so that** logging a transaction takes seconds.

- [x] Camera / gallery picker in the quick-add modal
- [x] Image sent to Gemini 2.0 Flash API to extract total amount and merchant name
- [x] Extracted values pre-fill the form; user reviews and confirms
- [x] Falls back gracefully if extraction fails (error state + null fields)

---

## Sprint 7 — Financial Intelligence & Investments

> **Goal**: Give users actionable insights and basic investment tracking, turning AFC into a true financial companion.

### US-23 · Monthly spending report [COMPLETED]
**As a** user, **I want** a monthly report showing my spending by category with trends,
**so that** I can understand where my money went and compare months.

- [x] `ReportScreen` with a selectable month/year picker
- [x] Pie chart of expenses by category for the selected month
- [x] Month-over-month comparison bar chart (current vs previous month per category)
- [x] Summary row: total income, total expenses, savings rate %
- [x] Export to PDF via `pdf` package

---

### US-24 · Savings goals [DONE]
**As a** user, **I want** to create savings goals with a target amount and deadline,
**so that** I can track progress towards things I'm saving for (e.g. travel, emergency fund).

- Backend: `GoalEntity` — `uuid`, `userId`, `name`, `targetAmount`, `currentAmount`, `deadline`, `icon`; full CRUD
- `GoalViewModel` — create, update progress, delete
- Goals screen with progress bars and days-remaining countdown
- Manual "add contribution" action that increments `currentAmount`
- Unit tests for contribution and progress calculation

---

### US-25 · Investment portfolio tracker ✅
**As a** user, **I want** to register my investments (stocks, fixed income, crypto) and see my total portfolio value,
**so that** I can monitor my net worth alongside my spending.

- Backend: `InvestmentEntity` — `uuid`, `userId`, `name`, `ticker` (optional), `type` (stock/fixed/crypto/other), `quantity`, `avgCost`, `currentPrice`; full CRUD
- `InvestmentViewModel` — CRUD for investments + manual price update
- Portfolio screen: total invested, current value, overall gain/loss %
- Net-worth card on dashboard (portfolio value, navigates to investments)
- Unit tests for gain/loss calculation

---

### US-26 · Bill reminders & push notifications ✅
**As a** user, **I want** to set reminders for upcoming bills,
**so that** I never miss a due date or incur a late fee.

- Backend: `BillEntity` — `uuid`, `userId`, `name`, `amount`, `dueDay` (day of month), `categoryId`; full CRUD
- `BillViewModel` — CRUD for bills
- Bills list screen with upcoming-this-month highlight (amber) and overdue (red)

---

### US-27 · Financial health score ✅
**As a** user, **I want** a simple score that summarises my financial health,
**so that** I have a single number to track and improve over time.

- Score (0–100) computed from: savings rate, limit adherence, goal progress, expense variance month-over-month
- Score card on dashboard with colour coding (red / yellow / green)
- Breakdown tooltip explaining each contributing factor (4 sub-scores of 25 pts each)
- Historical score trend (last 6 months) as a small sparkline chart
- Unit tests for scoring formula (37 tests)

---

## Sprint 8 — Brand Identity & Visual Language (US-33–37) ✅

### US-33 · Brand color system & typography scale ✅
- Primary color (`#10B981` emerald), full colour palette, typography scale defined in `app_theme.dart`

### US-34 · Custom app icon & branded splash screen ✅
- App icons (dev/prod) via `flutter_launcher_icons`; native splash screen configured

### US-35 · Consistent iconography system ✅
- `AppIcons` constants class; icon list for goals/categories; `cupertino_icons` + Material Icons

### US-36 · Dark mode & theme toggle ✅
- `ThemeViewModel` (light / dark / system); `ThemeMode` propagated through `MyApp`

### US-37 · Branded empty states
- `EmptyState` widget with icon + message; applied to all list screens

---

## Sprint 9 — User Experience & Interaction Design (US-38–44)

### US-38 · Onboarding flow (first-time user) ✅
- [x] `OnboardingScreen` (4-page `PageView`, dot indicators); `SharedPreferences` `onboarding_done` flag; `HomeScreen` routes to `/onboarding` on first launch

---

### US-39 · Skeleton loading screens ✅
- [x] `SkeletonList` with shimmer animation (`AnimationController` + `LinearGradient`); respects `MediaQuery.disableAnimations`

---

### US-40 · Animations for the app ✅
- [x] Chart entrance animations; staggered list entries; animated scorecards & sparklines

---

### US-41 · User profile & settings screen ✅
- [x] SettingsViewModel + SettingsScreen (/settings); Profile, Appearance, Notifications, Data, About sections; gear icon on dashboard

---

### US-42 · Contextual error states with retry ✅
- [x] ErrorState widget with retry button; replaces bare error text on all list screens

---

### US-43 · Pull-to-refresh on all list screens
- `RefreshIndicator` on transactions, categories, limits, recurring, goals list screens

---

### US-44 · Accessibility & inclusive design ✅
- [x] Semantics labels on FAB + settings button; tooltip on all NavigationDestinations; accessibility_checklist.md

---

## Sprint 10 — Establish AFC Design System (US-33b–44b)

Full migration to a custom Material 3 design system:

- `AppCard`, `AppButton`, `AppIconButton`, `AppTextField`, `AppDialog`, `Gap` widgets
- `AppColors`, `AppTextStyles`, `AppSpacing` constants
- `design_system.dart` barrel export
- All 25 screens migrated — `hide Column, Row, Expanded` clauses removed
- `ColorScheme.fromSeed()` with `useMaterial3: true`

---

## Sprint 11 — Design Polish & Navigation Overhaul (US-45–59)

### US-45 · Fix primary color propagation
- Explicit `primary: AppColors.primary, onPrimary: AppColors.onPrimary` overrides in `ColorScheme.fromSeed()` (both light and dark themes)

### US-46 · Fix HomeCard internal layout
- Added `padding: const EdgeInsets.all(16)` to `AppCard` in `HomeCard`; corrected icon circle sizing

### US-47 · Fix light/dark mode card adaptation
- `AppCard` and `AppIconButton` now use `Theme.of(context).brightness` (responds to theme changes)

### US-48 · Scaffold wrapper for all push-route screens
- Every `context.push()` screen wrapped in `Scaffold` (Material surface + background colour); form screens get `AppBar` with `BackButton`

### US-49 · Fix OFX/CSV encoding (Latin-1 fallback)
- Import parser tries `utf8.decode` first; falls back to `latin1.decode` on `FormatException`; fixes garbled "transferência" from Nubank exports

### US-50 · Bottom nav reorganisation (6→4 tabs)
- Tabs: Home | Transactions | Limits | Goals
- Categories moved to Settings screen ("Gerenciar categorias" tile)
- Recurring moved to Transactions header (repeat icon button)
- `lista_categorias.dart` and `lista_recorrentes.dart` converted to push routes with back button

### US-51 · Form screens as BottomSheet
- `showFormSheet<T>()` utility (`DraggableScrollableSheet`, 90% initial, 50–95% range)
- All create/edit forms shown as draggable bottom sheets

### US-53 · Fix "Ver Todas" navigation
- `context.go('/lista-transacoes')` correctly switches to the Transactions tab in `StatsWidget`

### US-56 · Category chip selector in all form screens
- Replaced `DropdownButtonFormField` for categories with `Wrap` of tappable chips in all four form screens
- Inline "Nova" chip triggers add-category dialog (auto-selects new category)

### US-57 · Fix showInputDialog use-after-dispose crash
- `showInputDialog` in `app_dialog.dart` wraps content in `_InputDialog` (`StatefulWidget`) so `TextEditingController` is owned and disposed by `State.dispose()`

### US-58 · Home page "Estatísticas" — remove line chart, add savings summary
- Removed line chart (not useful to users)
- Replaced with "Resumo do mês" card: taxa de poupança %, receita do mês, gastos do mês, "Ver relatório" link

### US-59 · Recent transaction card styling improvement
- `LastTransactions` widget redesigned: colour-coded direction arrow (green ↓ income / red ↑ expense), category name, formatted amount — wrapped in `AppCard`

---

## Sprint 12 — Financial Independence Engine (US-60–67)

> **Goal**: Elevate AFC from an expense tracker into a financial independence tool.

### US-60 · FIRE Calculator (Financial Independence, Retire Early)
**As a** user, **I want** to know my FIRE number and how long it will take me to reach it,
**so that** I can understand exactly when I could stop relying on active income.

- Backend: `POST /calculators/fire` — `fireNumber`, `monthsToFire?`, `retirementDate?`, `yearlyTimeline`
- Formula: `fireNumber = (monthlyExpenses × 12) / SWR`; month-by-month compound growth loop
- `FireCalculatorScreen` — inputs: monthly expenses, current portfolio, monthly savings, annual return %
- Presets: Lean FIRE (3%), Padrão (4%), Fat FIRE (5%) — preset chips
- Results card: FIRE number in BRL, time to FIRE, estimated retirement date
- `fl_chart` LineChart showing portfolio growth curve vs FIRE number (dashed horizontal reference line)
- `_FireCard` on Dashboard linking to `/fire-calculadora`
- 11 unit tests

---

### US-61 · Compound Interest Simulator
**As a** user, **I want** to simulate how my investments grow over time given a monthly contribution and interest rate,
**so that** I can see the real impact of investing consistently.

- Backend: `POST /calculators/compound` — `finalAmount`, `totalInvested`, `totalInterest`, `yearlyTimeline`
- Inputs: initial amount, monthly contribution, annual rate %, period in years
- Results card: final amount, total invested, total interest + visual composition bar
- `fl_chart` LineChart with area fill; "Comparar taxas" toggle overlays 6%, 10%, 14% comparison curves
- `_CompoundInterestCard` on Dashboard linking to `/juros-compostos`
- 11 unit tests

---

### US-62 · Portfolio Performance Dashboard
**As a** user, **I want** to see my portfolio's overall ROI, allocation breakdown, and performance over time,
**so that** I can evaluate whether my investments are on track.

- `PortfolioViewModel` — per-position metrics (`totalCost`, `currentValue`, `profit`, `roiPercent`) and portfolio summary
- `PortfolioDashboardScreen` — overall ROI card, allocation donut (PieChart), best/worst highlight tiles, position list sorted by value
- Colour coding per type: Ações (blue), Renda Fixa (green), Cripto (orange), Outros (purple)
- `_PortfolioCard` on Dashboard linking to `/portfolio-dashboard`
- 8 unit tests

---

### US-63 · Passive Income Tracker
**As a** user, **I want** to track my passive income streams (dividends, interest, rental income),
**so that** I can monitor how close I am to covering my expenses with passive income.

- Backend: `PassiveIncomeEntity` — `uuid`, `userId`, `source` (dividend/interest/rent/other), `amount`, `frequency` (monthly/quarterly/annual), `assetId?`; full CRUD
- `PassiveIncomeViewModel` — `loadStreams`, `add`, `update`, `delete`; sorted by amount desc
- Passive income screen: swipe-to-delete stream cards, total monthly equivalent summary card
- `monthlyEquivalent()` helper: monthly×1, quarterly÷3, annual÷12
- `_PassiveIncomeCard` on Dashboard → `/renda-passiva`
- 13 unit tests

---

### US-64 · Net Worth Evolution Chart
**As a** user, **I want** to see how my net worth (assets minus liabilities) has grown over time,
**so that** I can track my wealth-building progress month by month.

- Backend: `NetWorthSnapshotEntity` — `uuid`, `userId`, `date`, `assets`, `liabilities`, `netWorth`; upsert endpoint
- `NetWorthViewModel` — `loadData`, `recordSnapshot`, `delete`; sorted by date asc
- `/patrimonio` screen: line chart showing last 13 months, assets/liabilities/monthly delta summary, history list
- `_PatrimonioCard` on Dashboard → `/patrimonio`
- 8 unit tests

---

### US-65 · Investment Goal Planner
**As a** user, **I want** to set an investment target (e.g. "R$ 1 million by 2040") and see the required monthly contribution,
**so that** I know exactly how much to invest each month to reach my goal.

- Backend: `POST /calculators/investment-goal` — FV annuity formula solved for PMT; r=0 fallback to linear
- Result: `requiredMonthlyContribution`, `totalContributed`, `totalInterestEarned`, `yearlyTimeline`
- `/meta-investimento` screen: 4-input form, required monthly contribution card, composition bar, line chart
- `_InvestmentGoalCard` on Dashboard → `/meta-investimento`
- 10 unit tests

---

### US-66 · Inflation-Adjusted Projections
**As a** user, **I want** all long-term projections to show real (inflation-adjusted) values,
**so that** I understand what my money will actually buy in the future.

- Backend: `InflationCalculator` — `realValue()`, `realAnnualReturnPercent()`, `adjustTimeline()`; default IPCA 4.5%
- "Ajuste de Inflação" toggle on FIRE Calculator and Compound Interest screens
- 10 unit tests

---

### US-68 · Brazilian Market Opportunities Feed
**As a** user, **I want** to see top dividend-paying Brazilian stocks and compare their yield against fixed-income benchmarks (CDI, Selic, Tesouro Direto),
**so that** I can spot attractive investment opportunities without leaving the app.

- Data source: Brapi free tier — `/api/quote/{tickers}?fundamental=true`, `/api/v2/prime-rate?country=brazil`
- `BrapiService` — `fetchQuotes(List<String>)`, `fetchCdiRate()`, `fetchHistory(String)` with graceful fallbacks
- `MarketQuoteEntity` (display-only, not persisted): `ticker`, `name`, `price`, `changePercent`, `dividendYield`, `isFii`, `priceEarnings?`, `sector`; `dyVsCdi(double cdiRate)` helper
- `MarketOpportunityViewModel` — fetches 15 curated equities + 12 FIIs; fetches CDI; sorts by DY desc; 30-min in-memory TTL
- `OportunidadesScreen` — filter chips (Todos / Ações / FIIs) + sort chips (Maior DY / DY vs CDI / Menor P/L)
- `_BenchmarkBanner` — CDI % and Selic approximation
- Dashboard card — top 3 DY stocks with "Ver todas" link
- 10 unit tests

---

### US-69 · Stock Watchlist with Near Real-Time Quotes
**As a** user, **I want** to save a list of Brazilian stocks and track their prices in near real-time,
**so that** I can monitor opportunities I'm watching without opening a brokerage app.

- Data source: Brapi `/api/quote/{tickers}?fundamental=true` (batch ≤10) + 5-day history for sparklines; 60-second polling
- Backend: `WatchlistEntity` — `uuid`, `userId`, `ticker`, `addedAt`, `alertThreshold?`; CRUD
- `WatchlistViewModel` — `loadWatchlist`, `addTicker`, `removeTicker`, `setAlert`, `refresh`; batched quote fetching
- `ListaWatchlist` — swipe-to-delete, alert bell when threshold triggered, sparkline, DY%/P/L metrics
- Bookmark icon on `OportunidadesScreen` cards; `/watchlist` route
- 13 unit tests

---

### US-67 · Financial Independence Score & Milestones
**As a** user, **I want** a clear score showing how close I am to financial independence,
**so that** I have a single motivating number to grow.

- FI Score (0–100): `(monthly_passive_income / monthly_expenses) × 100`, capped at 100
- `FiScoreViewModel` — fetches passive income + transactions; computes score + 6-month sparkline
- Milestone badges (10 / 25 / 50 / 75 / 100%) on Dashboard card — filled when achieved
- `_FiScoreCard` on Dashboard — score %, label, sparkline, progress bar, milestone row
- 11 unit tests

---

## Sprint 14 — Privacy & Discoverability (US-77–78)

> **Goal**: Give users control over what they expose in public, and make complex financial concepts approachable.

### US-77 · Privacy mode — hide sensitive values
**As a** user, **I want** to tap an eye icon to instantly hide all monetary values on screen,
**so that** I can use the app in public without showing my financial data to bystanders.

- `PrivacyViewModel` — simple `bool` toggle (hidden/visible), resets on app restart
- `PrivacyText` widget — wraps any monetary string; shows `"•••••"` with `AnimatedSwitcher` when hidden
- Eye icon added to dashboard header
- `PrivacyText` applied to all monetary values: balance, income, expenses cards, recent transactions, limits, stats, portfolio value, FI Score

---

### US-78 · Tooltips for complex financial concepts
**As a** user, **I want** a help icon next to terms I don't understand (FIRE, FI Score, taxa de poupança),
**so that** I can learn what they mean without leaving the app.

- `AppTooltipIcon` widget — tappable icon using `Tooltip` with `triggerMode: tap` and 4s display duration
- Exported via `design_system.dart` barrel
- Applied to FIRE calculator, Compound Interest, FI Score card, Health Score sub-factors, Investment Goal

---

## Sprint 15 — Smart Data & Defaults (US-79–81)

> **Goal**: Reduce friction for new users and improve data quality by providing sensible defaults and smarter automatic categorisation.

### US-79 · Default categories seeded on first login
**As a** new user, **I want** to see a useful set of categories already available when I open the app,
**so that** I can start logging transactions immediately without configuring anything.

- Backend: on first successful sign-in, if user has no categories, seed a default set:
  Alimentação, Transporte, Moradia, Saúde, Lazer, Educação, Vestuário, Assinaturas, Restaurantes, Viagem, Investimentos, Salário, Freelance, Outros
- Each default category has a pre-assigned `iconType`
- Seeding is idempotent: guarded by a `seeded_categories` flag on the user record
- Unit test: seeding writes exactly N records when empty, writes 0 when flag already set

---

### US-80 · Transaction grouping on list screens
**As a** user, **I want** my transaction list to group similar entries,
**so that** I can quickly see patterns and totals for each type of spending.

- `TransactionGroup` — `label: String`, `transactions: List<TransactionEntity>`, `total: double`
- `TransactionGrouper` use case — rule-based pattern matching on `title` field:
  - `PIX` → "Transferências PIX"
  - `TED` / `DOC` → "Transferências bancárias"
  - `UBER` / `99` / `CABIFY` → "Transporte por app"
  - `IFOOD` / `RAPPI` / `DELIVERY` → "Delivery"
  - `MERCADO` / `SUPERMERCADO` / `PÃO DE AÇÚCAR` / `CARREFOUR` → "Supermercado"
  - `NETFLIX` / `SPOTIFY` / `AMAZON` / `APPLE` → "Assinaturas"
  - Remaining → "Outros"
- Toggle in `ListaTransacoes` header: "Por data" ↔ "Por grupo"
- Group header shows label + count + total amount for the group
- Unit tests for `TransactionGrouper` pattern matching (≥ 10 cases)

---

### US-81 · Smarter CSV/OFX import auto-categorisation
**As a** user, **I want** imported bank transactions to be automatically assigned to the right category,
**so that** I spend less time manually re-categorising after an import.

- `CategorizationMatcher` use case with 50+ Brazilian merchant patterns (iFood, Uber, Carrefour, Drogasil, Netflix, IPVA, Cemig, Udemy, etc.)
- Confidence score on each import candidate: `categoryConfidence: double` (0–1)
- Import parser runs matcher after parsing; resolved category ID written to each candidate
- Review screen confidence badge: green ≥ 0.8 ("Auto"), amber 0.5–0.8 ("Revisar"), red < 0.5 ("Manual")
- Unit tests: keyword matcher coverage for top 22 patterns

---

## Sprint 16 — Offline-First Architecture (US-82–83)

> **Goal**: Make the app fully usable without internet and keep users clearly informed when a feature needs connectivity.

### US-82 · Offline indicator and local operation queue
**As a** user, **I want** to create and modify data even when I have no internet connection,
**so that** I can log expenses on the go and trust they'll sync when I'm back online.

- `connectivity_plus` package; `ConnectivityService` singleton exposes `Stream<bool> isOnline`
- `OfflineBanner` widget — amber sticky banner "Sem conexão — dados serão sincronizados quando a internet voltar"
- `PendingOperationEntity` — `uuid`, `userId`, `type` (create/update/delete), `endpoint`, `payload: Map`, `createdAt`, `retries: int`; stored locally
- `SyncQueue` service — `enqueue(op)`, `flush()` (replays operations against backend when online), `clear()`
- All write operations: when offline → enqueue + optimistically update local state; when online → call API directly
- Features requiring connectivity (live quotes, watchlist prices): show `_OfflineUnavailableCard` placeholder
- `ConnectivityService` triggers `SyncQueue.flush()` automatically on reconnect
- Unit tests: enqueue, flush (applies ops in order), idempotency guard

---

### US-83 · Pending sync notifications page
**As a** user, **I want** to see a list of operations waiting to sync and be notified when they complete,
**so that** I always know the state of my data and can trust the app.

- `flutter_local_notifications` package; `LocalNotificationService` initialised in both entry points
- When `SyncQueue` has ≥ 1 pending op: persistent notification "X operações aguardando sincronização"
- When flush completes successfully: "Dados sincronizados com sucesso" notification
- When flush fails after 3 retries: "Falha ao sincronizar X operações" notification
- `PendingOpsScreen` (`/pendencias`) — operations grouped by resource type with retry button
- Badge on Settings icon when pending ops > 0
- Unit tests: notification scheduling on enqueue, clear on flush success, retry increment on flush failure

---

## Sprint 17 — Benefits & Sub-accounts (US-84–85)

> **Goal**: Support the financial reality of CLT employees (non-cash benefits) and PJ contractors (separate business finances).

### US-84 · Benefits wallet (CLT — VA, VT, VR)
**As a** CLT employee, **I want** to track my Vale Alimentação, Vale Transporte, and Vale Refeição balances separately,
**so that** I know how much benefit credit I've used and what's left this month.

- Backend: `BenefitEntity` — `uuid`, `userId`, `name`, `type` (va/vt/vr/other), `monthlyCredit`, `balance`, `color`; full CRUD + `deduct(amount)`
- `BenefitWalletScreen` (`/carteiras`) — card per benefit showing balance bar, monthly credit, deduct/edit/delete
- `_BenefitsCard` on Dashboard — total benefit balance, hidden when empty
- Unit tests for balance deduction and monthly reset logic (12 tests)

---

### US-85 · Company / sub-account tracking (PJ)
**As a** PJ contractor, **I want** to tag expenses to different "accounts" (Pessoal, Empresa, Cartão PJ),
**so that** I can see separate totals per context without mixing personal and business finances.

- Backend: `SubAccountEntity` — `uuid`, `userId`, `name`, `type` (personal/company/benefit), `color`, `icon`; CRUD
- `TransactionEntity` extended with optional `subAccountId` field (nullable, backwards-compatible)
- Sub-account selector chip row in transaction form and FAB sheet (only shown when ≥ 1 sub-account exists)
- `SubAccountsScreen` (`/sub-contas`) — list with per-account totals (income, expenses, balance); accessible from Settings
- Filter chip in `ListaTransacoes` to filter by sub-account
- Unit tests for per-account aggregation (11 tests)

---

## Sprint 18 — Quality, Reporting & Growth (US-86–89)

> **Goal**: Make the app production-ready: richer reports, stability monitoring, and a feedback loop for future improvements.

### US-86 · Enhanced PDF spending report
**As a** user, **I want** my exported PDF to contain all the financial data I care about in one place,
**so that** I can share it with an accountant or review it away from the app.

- PDF cover page: period, user name, generation date, summary table (income / expenses / savings rate / balance)
- Section 1 — Top expenses: ranked categories with amount + % of total
- Section 2 — Full transaction list: sorted by date, grouped by category, with running total per category
- Section 3 — Goals snapshot: name, target, current amount, progress %, days remaining
- Section 4 — Month-over-month comparison table: last 3 months side-by-side
- Section 5 — Investment summary: total cost, current value, overall gain/loss %
- Page numbers, header with AFC logo text, footer with generation timestamp
- Unit tests: PDF builder produces valid magic header, non-zero bytes, `MonthSummary` savings rate

---

### US-87 · In-app user feedback
**As a** user, **I want** to send feedback about the app directly from within it,
**so that** I can report problems or suggest improvements without leaving the app.

- Backend: `FeedbackEntity` — `uuid`, `userId`, `rating`, `message`, `appVersion`, `platform`, `createdAt`; write endpoint
- `FeedbackViewModel` — `submit(rating, message)`
- `FeedbackSheet` — 5-star rating row + optional text field + submit button; accessible from Settings
- NPS-style prompt after 7 days since first launch (shown once via `NpsFeedbackPrompt`)
- `dismissNpsPrompt()` marks prompt shown without submitting
- 11 unit tests: submit, persist, NPS logic (7-day check, already-shown guard, dismiss)

---

## Sprint 19 — Search, Export & Insights (US-90–93)

> **Goal**: Make the app feel complete for daily power users — find any transaction instantly, get data out in spreadsheet-friendly form, and surface actionable insights.

### US-90 · Transaction search & filter
**As a** user, **I want** to search and filter my transactions by keyword, date range, and type,
**so that** I can quickly locate any transaction without scrolling through the full list.

- Search bar at the top of `lista_transacoes.dart` — filters by `title` (case-insensitive substring)
- Date range picker — chip row opens a `DateRangePicker` dialog
- Type filter chips: Todas / Receitas / Despesas
- All three filters compose (AND logic) on the in-memory list
- Clear all filters button shown when any filter is active
- Unit tests: search, date range, type filter, combined filters, clear

---

### US-91 · CSV transaction export
**As a** user, **I want** to export my transactions to a CSV file,
**so that** I can analyse my data in a spreadsheet.

- `CsvExporter` use-case — pure Dart, converts `List<TransactionEntity>` + category names to RFC-4180 CSV bytes
- CSV columns: Data, Título, Categoria, Tipo, Valor
- Export button on the Report screen (alongside PDF button)
- `Share.shareXFiles` via `share_plus` to open system share sheet
- Unit tests: header row correct, data rows correct, special characters escaped

---

### US-92 · Spending insights on dashboard
**As a** user, **I want** to see smart insight cards on my dashboard,
**so that** I can spot unusual spending without manually reviewing reports.

- `InsightEngine` use-case — takes current-month and previous-month transaction lists, returns `List<SpendingInsight>`
- Insight types: `topCategory`, `biggestExpense`, `monthOverMonthDelta`, `savingsRateTrend`
- `InsightsCard` widget on `home_page.dart` — horizontal `PageView` of insight chips (hidden when no transactions)
- Unit tests: each insight type computed correctly, empty list when no data

---

### US-93 · Limit overspend push alert
**As a** user, **I want** to receive a push notification when I am approaching or have exceeded a spending limit,
**so that** I can adjust my spending before the month ends.

- `LimitAlertService` — checks all limits after every transaction create/update; fires notification at ≥ 80% (warning) or ≥ 100% (exceeded)
- Alert fires once per threshold crossing per category per month (tracks last-alerted month locally)
- Unit tests: alert fires at 80%, fires at 100%, does not fire twice in same month, does not fire below 80%

---
