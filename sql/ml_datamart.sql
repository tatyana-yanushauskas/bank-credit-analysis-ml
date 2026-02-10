/* 
Витрина данных для модели скоринга с признаками на основе оконных функций
Коммерческий проект для кредитного департамента банка
*/

SELECT
    a.id_client,
    b.name_city,
    -- Бинарный признак пола
    CASE 
        WHEN a.gender = 'M' THEN 1 
        ELSE 0 
    END AS nflag_gender,
    a.age,
    a.first_time,
    -- Бинарный признак наличия телефона
    CASE 
        WHEN a.cellphone IS NULL THEN 0 
        ELSE 1 
    END AS nflag_cellphone,
    a.is_active,
    a.cl_segm,
    a.amt_loan,
    -- Приведение даты к формату DATE
    a.date_loan::DATE,
    a.credit_type,
    -- Агрегаты по городу (оконные функции)
    SUM(a.amt_loan) OVER(PARTITION BY b.name_city) AS sum_credit_city,
    a.amt_loan::FLOAT / SUM(a.amt_loan) OVER(PARTITION BY b.name_city)::FLOAT AS share_credit_city,
    -- Агрегаты по типу кредита
    SUM(a.amt_loan) OVER(PARTITION BY a.credit_type) AS sum_credit_type,
    a.amt_loan::FLOAT / SUM(a.amt_loan) OVER(PARTITION BY a.credit_type)::FLOAT AS share_credit_type,
    -- Агрегаты по комбинации город + тип кредита
    SUM(a.amt_loan) OVER(PARTITION BY b.name_city, a.credit_type) AS sum_credit_city_type,
    a.amt_loan::FLOAT / SUM(a.amt_loan) OVER(PARTITION BY b.name_city, a.credit_type)::FLOAT AS share_credit_city_type,
    -- Количественные метрики
    COUNT(*) OVER(PARTITION BY b.name_city) AS cnt_credit_city,
    COUNT(*) OVER(PARTITION BY a.credit_type) AS cnt_credit_type,
    COUNT(*) OVER(PARTITION BY b.name_city, a.credit_type) AS cnt_credit_city_type
FROM skybank.late_collection_clients a
LEFT JOIN skybank.region_dict b
    ON a.id_city = b.id_city
WHERE a.amt_loan IS NOT NULL;
