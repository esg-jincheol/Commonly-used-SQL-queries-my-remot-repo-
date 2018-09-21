/****************************/
/* users that won something */
/****************************/
SELECT cohort, COUNT(DISTINCT user_id)
FROM
(
      SELECT *, SPLIT_PART(subsource, ',', 1) AS contest, SPLIT_PART(subsource, ',', 2) AS cohort, SPLIT_PART(subsource, ',', 3) AS leaderboard
      FROM karma_in 
      WHERE timestamp between '2018-09-19 09:00:00' AND '2018-09-19 21:00:00'
      ORDER BY cohort, user_id
)
GROUP BY cohort
;

/****************************/
/* users that won something */
/****************************/
SELECT *
FROM
(
  SELECT *, PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY final_karma_score) OVER (PARTITION BY cohort) AS cutoff_point_for_bronze 
  FROM
  (
    SELECT user_id, SPLIT_PART(subsource, ',', 2) AS cohort, MAX(currency_balance) AS final_karma_score
    FROM karma_in
    WHERE timestamp between '2018-09-19 09:00:00' AND '2018-09-19 21:00:00'
    GROUP BY user_id, cohort
    ORDER BY cohort, final_karma_score DESC
  )
  ORDER BY cohort, final_karma_score DESC
)
WHERE final_karma_score > cutoff_point_for_bronze
ORDER BY cohort, user_id
;

/**********************************************/
/* users that claimed award from contest: 535 */
/**********************************************/
SELECT *, SPLIT_PART(subsource, ',', 1) AS contest, SPLIT_PART(subsource, ',', 2) AS cohort, SPLIT_PART(subsource, ',', 3) AS leaderboard
FROM award 
WHERE subsource LIKE '%Contest%' AND timestamp >= '2018-09-19 21:00:00' AND contest = 'Contest: 535'
ORDER BY cohort, user_id
;

/**********************************************************/
/* users that haven't claimed award yet from contest: 535 */
/**********************************************************/
SELECT *
FROM
(
  SELECT *, PERCENTILE_CONT(0.1) WITHIN GROUP (ORDER BY final_karma_score) OVER (PARTITION BY cohort) AS cutoff_point_for_bronze 
  FROM
  (
    SELECT user_id, SPLIT_PART(subsource, ',', 2) AS cohort, MAX(currency_balance) AS final_karma_score
    FROM karma_in
    WHERE timestamp between '2018-09-19 09:00:00' AND '2018-09-19 21:00:00'
    GROUP BY user_id, cohort
    ORDER BY cohort, final_karma_score DESC
  )
  ORDER BY cohort, final_karma_score DESC
)
WHERE final_karma_score > cutoff_point_for_bronze AND user_id NOT IN (
                                                                      SELECT DISTINCT user_id
                                                                      FROM
                                                                        (
                                                                           SELECT *, SPLIT_PART(subsource, ',', 1) AS contest, SPLIT_PART(subsource, ',', 2) AS cohort, SPLIT_PART(subsource, ',', 3) AS leaderboard
                                                                           FROM award 
                                                                           WHERE subsource LIKE '%Contest%' AND timestamp >= '2018-09-19 21:00:00' AND contest = 'Contest: 535'
                                                                           ORDER BY cohort, user_id
                                                                        )
                                                                     )
ORDER BY cohort, user_id
;





