/***********************************************************/
/* BF420/PFGR User Interaction with Zeke (Mean and Median) */
/***********************************************************/
SELECT *
FROM
(
  SELECT date, user_id, CASE WHEN zeke_use_count IS NULL THEN 0 ELSE zeke_use_count END AS daily_zeke_use_count
  FROM
  (
    /* DAU id */
    SELECT DISTINCT user_id, date
    FROM session_begin
    WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
  )
  LEFT JOIN
  
  (
    /* zeke user_id */
    SELECT date, user_id, COUNT(*) AS zeke_use_count
    FROM
    (
      /* consider only materials */
      SELECT date, user_id, source, subsource, item_type, item_name
      FROM giftbox_in
      WHERE item_type = 'item' AND date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
    ) 
    WHERE  subsource = 'zekeChest'
    GROUP BY date, user_id
    ORDER BY date, user_id
  )
  USING(date, user_id)
)
LEFT JOIN

(
  SELECT date, user_id, CASE WHEN other_use_count IS NULL THEN 0 ELSE other_use_count END AS daily_other_use_count
  FROM
  (
    /* DAU id */
    SELECT DISTINCT user_id, date
    FROM session_begin
    WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
  )
  LEFT JOIN
  
  (
    /* non- zeke user_id */
    SELECT date, user_id, COUNT(*) AS other_use_count
    FROM
    (
      /* consider only materials */
      SELECT date, user_id, source, subsource, item_type, item_name
      FROM giftbox_in
      WHERE item_type = 'item' AND date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
    ) 
    WHERE  source != 'zekeChest'
    GROUP BY date, user_id
    ORDER BY date, user_id
  )
  USING(date, user_id)
)
USING(date, user_id)
;
