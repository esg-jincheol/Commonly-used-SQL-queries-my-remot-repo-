/****************************************************/
/* BF420/PFGR User Interaction with Zeke and Others */
/****************************************************/
SELECT date, user_id, source, subsource, item_type, MAX(level) AS level, COUNT(*) AS reward_count
FROM
(
  /* consider only materials */
  SELECT *
  FROM giftbox_in
  WHERE item_type = 'item' AND date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE - 1)
)
GROUP BY date, user_id, source, subsource, item_type
ORDER BY date, user_id, source, subsource, item_type
;



