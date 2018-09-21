/****************************************************************/
/* summary table for LTV (install_date, ltv_30, ltv_60, ltv_90) */
/****************************************************************/
SELECT
  install_date,
  AVG(CASE WHEN install_date <= CURRENT_DATE - INTERVAL '30 DAY' THEN LTV_30 END) as LTV_30,
  AVG(CASE WHEN install_date <= CURRENT_DATE - INTERVAL '60 DAY' THEN LTV_60 END) as LTV_60,
  AVG(CASE WHEN install_date <= CURRENT_DATE - INTERVAL '90 DAY' THEN LTV_90 END) as LTV_90
FROM
(
  SELECT
    user_id,
    install_date,
    SUM(CASE WHEN purchase_date BETWEEN install_date AND install_date + INTERVAL '29 DAY' THEN revenue ELSE 0 END) as LTV_30,
    SUM(CASE WHEN purchase_date BETWEEN install_date AND install_date + INTERVAL '59 DAY' THEN revenue ELSE 0 END) as LTV_60,
    SUM(CASE WHEN purchase_date BETWEEN install_date AND install_date + INTERVAL '89 DAY' THEN revenue ELSE 0 END) as LTV_90
  FROM
  (
    SELECT user_id, MIN(date) as install_date
    FROM install
    WHERE date BETWEEN '2018-01-01' AND '2018-12-31'
    GROUP BY user_id
  ) inst
  LEFT JOIN
  (
    SELECT
      user_id,
      date as purchase_date,
      SUM(converted) as revenue
    FROM purchases_view
    GROUP BY user_id, purchase_date
  ) pur
  USING(user_id)
  GROUP BY user_id, install_date
)
GROUP BY install_date


