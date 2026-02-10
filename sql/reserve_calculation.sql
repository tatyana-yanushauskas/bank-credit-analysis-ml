/* 
Расчёт банковских резервов под риск по кредитам из Москвы
Объединение данных из двух систем взыскания (UNION ALL)
*/

-- Резерв 90% для кредитов из позднего взыскания
SELECT
    a.id_client,
    a.amt_loan,
    a.amt_loan * 0.9 AS reserv
FROM skybank.late_collection_clients a
JOIN skybank.region_dict b
    ON a.id_city = b.id_city
WHERE b.name_city = 'Москва'
    AND a.amt_loan IS NOT NULL

UNION ALL

-- Резерв 60% для кредитов из раннего взыскания
SELECT
    a.id_client,
    a.amt_credit AS amt_loan,
    a.amt_credit * 0.6 AS reserv
FROM skybank.early_collection_clients a
JOIN skybank.region_dict b
    ON a.id_city = b.id_city
WHERE b.name_city = 'Москва'
    AND a.amt_credit IS NOT NULL;
