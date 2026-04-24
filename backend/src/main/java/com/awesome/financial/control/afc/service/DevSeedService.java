package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.model.Bill;
import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.model.Investment;
import com.awesome.financial.control.afc.model.InvestmentType;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.RecurrenceFrequency;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.BillRepository;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.GoalRepository;
import com.awesome.financial.control.afc.repository.InvestmentRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TemplateRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Profile("local")
@RequiredArgsConstructor
public class DevSeedService {

    private final CategoryRepository categoryRepository;
    private final LimitRepository limitRepository;
    private final TransactionRepository transactionRepository;
    private final GoalRepository goalRepository;
    private final RecurringTransactionRepository recurringTransactionRepository;
    private final InvestmentRepository investmentRepository;
    private final BillRepository billRepository;
    private final TemplateRepository templateRepository;
    private final SecureRandom random = new SecureRandom();

    @Transactional
    public void seed() {
        // 1. Categories
        Category alimentacao = saveCategory("Alimentação");
        Category transporte = saveCategory("Transporte");
        Category moradia = saveCategory("Moradia");
        Category lazer = saveCategory("Lazer");
        Category saude = saveCategory("Saúde");
        Category educacao = saveCategory("Educação");
        Category investimentosCat = saveCategory("Investimentos");
        saveCategory("Salário");
        saveCategory("Freelance");
        saveCategory("Presentes");

        // 2. Limits
        saveLimit(alimentacao, "1500.00");
        saveLimit(transporte, "500.00");
        saveLimit(lazer, "800.00");
        saveLimit(saude, "400.00");
        saveLimit(educacao, "1000.00");

        Instant now = Instant.now();
        Instant oneYearAgo = now.minus(365, ChronoUnit.DAYS);

        // 3. Historical Data (Last 12 months)
        for (int i = 11; i >= 0; i--) {
            Instant monthDate = now.minus(i * 30L, ChronoUnit.DAYS);

            // Income
            saveTransaction(
                    "Salário Mensal", "6200.00", TransactionType.INCOME, "Salário", monthDate);
            if (i % 4 == 0) {
                saveTransaction(
                        "Projeto Extra",
                        "2500.00",
                        TransactionType.INCOME,
                        "Freelance",
                        monthDate.plus(10, ChronoUnit.DAYS));
            }

            // Fixed Expenses
            saveTransaction(
                    "Aluguel Apartamento",
                    "2200.00",
                    TransactionType.EXPENSE,
                    moradia.getName(),
                    monthDate.plus(5, ChronoUnit.DAYS));
            saveTransaction(
                    "Internet Fibra",
                    "149.90",
                    TransactionType.EXPENSE,
                    moradia.getName(),
                    monthDate.plus(5, ChronoUnit.DAYS));
            saveTransaction(
                    "Conta de Luz",
                    String.format(Locale.US, "%.2f", 180.0 + (random.nextDouble() * 100)),
                    TransactionType.EXPENSE,
                    moradia.getName(),
                    monthDate.plus(20, ChronoUnit.DAYS));
            saveTransaction(
                    "Plano de Saúde",
                    "450.00",
                    TransactionType.EXPENSE,
                    saude.getName(),
                    monthDate.plus(1, ChronoUnit.DAYS));

            // Variable Expenses
            saveTransaction(
                    "Compras do Mês",
                    String.format(Locale.US, "%.2f", 600.0 + (random.nextDouble() * 300)),
                    TransactionType.EXPENSE,
                    alimentacao.getName(),
                    monthDate.plus(7, ChronoUnit.DAYS));
            saveTransaction(
                    "Restaurante/Ifood",
                    String.format(Locale.US, "%.2f", 150.0 + (random.nextDouble() * 250)),
                    TransactionType.EXPENSE,
                    alimentacao.getName(),
                    monthDate.plus(15, ChronoUnit.DAYS));
            saveTransaction(
                    "Uber/Mobilidade",
                    String.format(Locale.US, "%.2f", 100.0 + (random.nextDouble() * 150)),
                    TransactionType.EXPENSE,
                    transporte.getName(),
                    monthDate.plus(12, ChronoUnit.DAYS));

            if (i % 2 == 0) {
                saveTransaction(
                        "Cinema/Teatro",
                        "120.00",
                        TransactionType.EXPENSE,
                        lazer.getName(),
                        monthDate.plus(25, ChronoUnit.DAYS));
            }

            // Regular Investment Contributions
            saveTransaction(
                    "Aporte Mensal Ações",
                    "1000.00",
                    TransactionType.EXPENSE,
                    investimentosCat.getName(),
                    monthDate.plus(2, ChronoUnit.DAYS));
        }

        // 4. Investments (Created at different times)
        Investment petr4 =
                saveInvestment(
                        "Petrobras",
                        "PETR4",
                        InvestmentType.STOCK,
                        "150",
                        "28.50",
                        "38.20",
                        now.minus(320, ChronoUnit.DAYS));
        Investment vale3 =
                saveInvestment(
                        "Vale",
                        "VALE3",
                        InvestmentType.STOCK,
                        "80",
                        "65.00",
                        "72.50",
                        now.minus(240, ChronoUnit.DAYS));
        Investment btc =
                saveInvestment(
                        "Bitcoin",
                        "BTC",
                        InvestmentType.CRYPTO,
                        "0.035",
                        "210000.00",
                        "435000.00",
                        now.minus(365, ChronoUnit.DAYS));
        Investment cdb =
                saveInvestment(
                        "CDB Liquidez Diária",
                        "",
                        InvestmentType.FIXED_INCOME,
                        "1",
                        "15000.00",
                        "16850.00",
                        now.minus(365, ChronoUnit.DAYS));
        Investment ivvb11 =
                saveInvestment(
                        "S&P 500 ETF",
                        "IVVB11",
                        InvestmentType.STOCK,
                        "40",
                        "210.00",
                        "285.00",
                        now.minus(180, ChronoUnit.DAYS));

        // 5. Passive Income (Dividends related to investments)
        for (int i = 10; i >= 0; i--) {
            Instant monthDate = now.minus(i * 30L, ChronoUnit.DAYS);
            if (i >= 0) { // All months for PETR4
                savePassiveTransaction("Dividendos PETR4", "185.50", petr4, monthDate);
            }
            if (i % 3 == 0) {
                savePassiveTransaction("Dividendos VALE3", "110.20", vale3, monthDate);
            }
            savePassiveTransaction("Rendimentos CDB", "145.00", cdb, monthDate);
        }

        // 6. Goals
        saveGoal("Reserva de Emergência", "50000.00", "22500.00", now.plus(365, ChronoUnit.DAYS));
        saveGoal("Intercâmbio Canadá", "35000.00", "12400.00", now.plus(540, ChronoUnit.DAYS));
        saveGoal("Apartamento Próprio", "250000.00", "45000.00", now.plus(1800, ChronoUnit.DAYS));

        // 7. Bills (Future/Pending)
        saveBill("IPVA Corolla", "3200.00", 15);
        saveBill("Seguro Residencial", "850.00", 28);
        saveBill("Condomínio", "680.00", 10);
        saveBill("Assinatura Adobe", "125.00", 22);

        // 8. Recurring Transactions
        saveRecurringTransaction(
                "Netflix Premium",
                "55.90",
                TransactionType.EXPENSE,
                lazer.getName(),
                RecurrenceFrequency.MONTHLY,
                now.plus(12, ChronoUnit.DAYS));
        saveRecurringTransaction(
                "Academia",
                "110.00",
                TransactionType.EXPENSE,
                saude.getName(),
                RecurrenceFrequency.MONTHLY,
                now.plus(5, ChronoUnit.DAYS));
        saveRecurringTransaction(
                "Curso de Inglês",
                "350.00",
                TransactionType.EXPENSE,
                educacao.getName(),
                RecurrenceFrequency.MONTHLY,
                now.plus(15, ChronoUnit.DAYS));
    }

    @Transactional
    public void reset() {
        recurringTransactionRepository.deleteAll();
        transactionRepository.deleteAll();
        templateRepository.deleteAll();
        billRepository.deleteAll();
        investmentRepository.deleteAll();
        goalRepository.deleteAll();
        limitRepository.deleteAll();
        categoryRepository.deleteAll();
    }

    private Category saveCategory(String name) {
        Category c = new Category();
        c.setName(name);
        return categoryRepository.save(c);
    }

    private void saveLimit(Category category, String amount) {
        Limit l = new Limit();
        l.setCategory(category);
        l.setAmount(new BigDecimal(amount));
        limitRepository.save(l);
    }

    private void saveTransaction(
            String description,
            String amount,
            TransactionType type,
            String category,
            Instant occurredAt) {
        saveTransaction(description, amount, type, category, occurredAt, false, null);
    }

    private void saveTransaction(
            String description,
            String amount,
            TransactionType type,
            String category,
            Instant occurredAt,
            boolean isPassive,
            java.util.UUID investmentId) {
        Transaction t = new Transaction();
        t.setDescription(description);
        t.setAmount(new BigDecimal(amount));
        t.setType(type);
        t.setCategory(category);
        t.setOccurredAt(occurredAt);
        t.setPassive(isPassive);
        t.setInvestmentId(investmentId);
        transactionRepository.save(t);
    }

    private void savePassiveTransaction(
            String description, String amount, Investment investment, Instant occurredAt) {
        saveTransaction(
                description,
                amount,
                TransactionType.INCOME,
                "Dividendos",
                occurredAt,
                true,
                investment != null ? investment.getId() : null);
    }

    private void saveGoal(String name, String target, String current, Instant deadline) {
        Goal g = new Goal();
        g.setName(name);
        g.setTargetAmount(new BigDecimal(target));
        g.setCurrentAmount(new BigDecimal(current));
        g.setDeadline(deadline);
        goalRepository.save(g);
    }

    private void saveRecurringTransaction(
            String description,
            String amount,
            TransactionType type,
            String category,
            RecurrenceFrequency frequency,
            Instant nextDueAt) {
        RecurringTransaction rt = new RecurringTransaction();
        rt.setDescription(description);
        rt.setAmount(new BigDecimal(amount));
        rt.setType(type);
        rt.setCategory(category);
        rt.setFrequency(frequency);
        rt.setNextDueAt(nextDueAt);
        recurringTransactionRepository.save(rt);
    }

    private Investment saveInvestment(
            String name,
            String ticker,
            InvestmentType type,
            String quantity,
            String avgCost,
            String currentPrice) {
        return saveInvestment(name, ticker, type, quantity, avgCost, currentPrice, Instant.now());
    }

    private Investment saveInvestment(
            String name,
            String ticker,
            InvestmentType type,
            String quantity,
            String avgCost,
            String currentPrice,
            Instant createdAt) {
        Investment i = new Investment();
        i.setName(name);
        i.setTicker(ticker);
        i.setType(type);
        i.setQuantity(new BigDecimal(quantity));
        i.setAvgCost(new BigDecimal(avgCost));
        i.setCurrentPrice(new BigDecimal(currentPrice));
        i.setCreatedAt(createdAt);
        return investmentRepository.save(i);
    }

    private void saveBill(String name, String amount, int dueDay) {
        Bill b = Bill.builder().name(name).amount(new BigDecimal(amount)).dueDay(dueDay).build();
        billRepository.save(b);
    }

    public List<String> seededCategories() {
        return categoryRepository.findAll().stream().map(Category::getName).toList();
    }

    public long transactionCount() {
        return transactionRepository.count();
    }

    public long limitCount() {
        return limitRepository.count();
    }
}
