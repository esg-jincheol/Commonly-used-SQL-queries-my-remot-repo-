/***************/
/* date       */
/* user_id     */
/* spent_money */
/***************/
SELECT date, user_id, 
    CASE
      WHEN spent_money IS NULL THEN 0
      ELSE spent_money
    END AS spent_money
FROM
(
  SELECT DISTINCT date, user_id
  FROM session_begin
  WHERE date BETWEEN (CURRENT_DATE - 7) AND (CURRENT_DATE - 1)
)
LEFT JOIN

(
  SELECT date, user_id, SUM(converted) AS spent_money
  FROM purchases_view
  WHERE date BETWEEN (CURRENT_DATE - 7) AND (CURRENT_DATE - 1)
  GROUP BY date, user_id
  ORDER BY date, user_id
)
USING(date, user_id)



