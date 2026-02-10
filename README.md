# Анализ кредитного портфеля и создание витрины для ML-модели

**Заказчик:** Кредитный департамент банка (NDA).  
**Задача:** Проанализировать портфортфель просроченных кредитов, выделить риск-сегменты и подготовить структурированную витрину данных для команды Data Science.  
**Срок:** 5 рабочих дней.  
**Стек:** PostgreSQL, оконные функции, сложные JOIN, UNION ALL.

## Результат

1.  **Витрина для ML-модели:** Создана таблица с 20+ признаками, включая относительные метрики (доля клиента в портфеле города/продукта).
2.  **Автоматизация расчётов:** Настроен расчёт банковских резервов через объединение данных из разных источников.
3.  **Сегментация риска:** Выделены группы клиентов с повышенной вероятностью дефолта (молодёжь без телефона, неполные данные).

## Фрагмент основного запроса

```sql
/* Создание признаков для модели скоринга через оконные функции */
SELECT
    a.id_client,
    b.name_city,
    CASE WHEN a.gender = 'M' THEN 1 ELSE 0 END AS nflag_gender,
    a.amt_loan,
    -- Доля клиента в портфеле города
    a.amt_loan::FLOAT / SUM(a.amt_loan) OVER(PARTITION BY b.name_city)::FLOAT AS share_city,
    -- Доля клиента в портфеле по типу продукта
    a.amt_loan::FLOAT / SUM(a.amt_loan) OVER(PARTITION BY a.credit_type)::FLOAT AS share_type,
    -- Количество кредитов в сегменте (город + тип)
    COUNT(*) OVER(PARTITION BY b.name_city, a.credit_type) AS peers_in_segment
FROM skybank.late_collection_clients a
LEFT JOIN skybank.region_dict b
    ON a.id_city = b.id_city
WHERE a.amt_loan IS NOT NULL;
