/*************************************/
/* BF420/PFGR potbuck spent for Zeke */
/*************************************/
SELECT *
FROM
(
  SELECT date, source, SUM(claim_count) AS daily_total_claim_count, AVG(claim_count) AS avg_claim_count, SUM(potbuck_spent) AS daily_total_potbuck_spent, AVG(potbuck_spent) AS avg_potbuck_spent
  FROM
  (
    /* date, user_id, source, claim_count, potbuck_spent */
    SELECT *
    FROM
    (
      SELECT DISTINCT user_id, date
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
    )
    LEFT JOIN
    (
      /* date, user_id, source, claim_count, potbuck_spent*/
      SELECT date, user_id, source, COUNT(*) AS claim_count, SUM(amount) AS potbuck_spent
      FROM potbucks_out
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
      GROUP BY date, user_id, source
      ORDER BY date, user_id, source
    )
    USING(date, user_id)
  )
  GROUP BY date, source
  ORDER BY date, source
)
LEFT JOIN

(
  /* date, user_id, source, claim_count, potbuck_spent*/
  SELECT date, source, COUNT(DISTINCT user_id) AS number_of_spenders
  FROM potbucks_out
  WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
  GROUP BY date, source
  ORDER BY date, source

)
USING(date, source)

LEFT JOIN
(
  /* DAU id */
  SELECT date, COUNT(DISTINCT user_id) AS DAU
  FROM session_begin
  WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
  GROUP BY date
  ORDER BY date
)
USING(date)
ORDER BY date, source
;


