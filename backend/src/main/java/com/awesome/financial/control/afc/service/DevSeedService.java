package com.awesome.financial.control.afc.service;

import com.awesome.financial.control.afc.model.Category;
import com.awesome.financial.control.afc.model.Goal;
import com.awesome.financial.control.afc.model.Limit;
import com.awesome.financial.control.afc.model.RecurrenceFrequency;
import com.awesome.financial.control.afc.model.RecurringTransaction;
import com.awesome.financial.control.afc.model.Transaction;
import com.awesome.financial.control.afc.model.TransactionType;
import com.awesome.financial.control.afc.repository.CategoryRepository;
import com.awesome.financial.control.afc.repository.GoalRepository;
import com.awesome.financial.control.afc.repository.LimitRepository;
import com.awesome.financial.control.afc.repository.RecurringTransactionRepository;
import com.awesome.financial.control.afc.repository.TransactionRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
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

    @Transactional
    public void seed() {
        Category alimentacao = saveCategory("Alimentação");
        Category transporte = saveCategory("Transporte");
        Category moradia = saveCategory("Moradia");
        Category lazer = saveCategory("Lazer");
        Category saude = saveCategory("Saúde");
        saveCategory("Salário");

        saveLimit(alimentacao, "1000.00");
        saveLimit(transporte, "300.00");
        saveLimit(lazer, "500.00");

        Instant today = Instant.now();
        Instant lastMonth = today.minus(35, ChronoUnit.DAYS);

        saveTransaction("Salário", "5000.00", TransactionType.INCOME, null, today);
        saveTransaction("Freelance", "1500.00", TransactionType.INCOME, null, today);
        saveTransaction(
                "Supermercado", "350.00", TransactionType.EXPENSE, alimentacao.getName(), today);
        saveTransaction("Uber", "45.00", TransactionType.EXPENSE, transporte.getName(), today);
        saveTransaction("Netflix", "35.00", TransactionType.EXPENSE, lazer.getName(), today);
        saveTransaction("Aluguel", "1800.00", TransactionType.EXPENSE, moradia.getName(), today);
        saveTransaction("Farmácia", "120.00", TransactionType.EXPENSE, saude.getName(), today);
        saveTransaction("Academia", "100.00", TransactionType.EXPENSE, saude.getName(), lastMonth);
        saveTransaction(
                "Restaurante", "80.00", TransactionType.EXPENSE, alimentacao.getName(), lastMonth);
        saveTransaction(
                "Combustível", "200.00", TransactionType.EXPENSE, transporte.getName(), lastMonth);

        saveGoal("Viagem Japão", "15000.00", "2000.00", today.plus(365, ChronoUnit.DAYS));
        saveGoal("Reserva de Emergência", "20000.00", "5000.00", today.plus(730, ChronoUnit.DAYS));

        saveRecurringTransaction(
                "Internet",
                "120.00",
                TransactionType.EXPENSE,
                moradia.getName(),
                RecurrenceFrequency.MONTHLY,
                today.plus(15, ChronoUnit.DAYS));
        saveRecurringTransaction(
                "Spotify",
                "21.90",
                TransactionType.EXPENSE,
                lazer.getName(),
                RecurrenceFrequency.MONTHLY,
                today.plus(5, ChronoUnit.DAYS));
    }

    @Transactional
    public void reset() {
        recurringTransactionRepository.deleteAll();
        goalRepository.deleteAll();
        transactionRepository.deleteAll();
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
        Transaction t = new Transaction();
        t.setDescription(description);
        t.setAmount(new BigDecimal(amount));
        t.setType(type);
        t.setCategory(category);
        t.setOccurredAt(occurredAt);
        transactionRepository.save(t);
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
