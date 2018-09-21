/*****************************************************************************************************/
/* summary table for 30 day LTV (install_date, total_spent, install_user_count, d30_ltv) - version 1 */
/*****************************************************************************************************/
SELECT install_date, SUM(daily_spent) AS total_spent, COUNT(DISTINCT user_id) AS install_user_count, total_spent/install_user_count AS d30_ltv
FROM
(

  /*******************************/
  /* spent money within 30 days */
  /*******************************/
  SELECT *
  FROM
  (
    /*******************************/
    /* install_date before 30 days */
    /*******************************/
    SELECT *
    FROM
    (
      /*************************************************************************/
      /* long table (user_id, install_date, date, daily_spent, time_diff_days) */
      /*************************************************************************/
      SELECT *, DATEDIFF('DAY', install_date, date) AS time_diff_days
      FROM
      (
        /**************************************/
        /* long table (install_date, user_id) */
        /**************************************/
        SELECT install_date, user_id
        FROM
        (
          SELECT *
          FROM
          (
            SELECT DISTINCT user_id, date AS install_date
            FROM install
            WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
          ) AS install_table
          LEFT JOIN 
          (
            SELECT DISTINCT user_id AS user_id_from_session_begin, date AS same_date_session_begin
            FROM session_begin
            WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
          ) AS same_date_session_begin_table
        
          ON(install_table.user_id = same_date_session_begin_table.user_id_from_session_begin AND install_table.install_date = same_date_session_begin_table.same_date_session_begin - 0) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
        )
        WHERE same_date_session_begin IS NOT NULL
        ORDER BY install_date
      )
      LEFT JOIN
      
      (
        /*******************************************/
        /* long table (date, user_id, daily_spent) */
        /*******************************************/
        SELECT date, user_id, SUM(converted) AS daily_spent
        FROM purchases_view
        WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
        GROUP BY date, user_id
        ORDER BY date, user_id
      )
      USING(user_id)
      /* long table (user_id, install_date, date, daily_spent, time_diff_days) */
    )
    WHERE install_date <= (CURRENT_DATE - INTERVAL '30 DAY') /* tunning parameter */

  )
  WHERE time_diff_days <= 30 OR time_diff_days IS NULL

)
GROUP BY install_date
ORDER BY install_date
;





/*****************************************************************************************************/
/* summary table for 30 day LTV (install_date, total_spent, install_user_count, d30_ltv) - version 2 */
/*****************************************************************************************************/
SELECT install_date, SUM(daily_spent) AS total_spent, COUNT(DISTINCT user_id) AS install_user_count, total_spent/install_user_count AS d30_ltv
FROM
(
  /*******************************/
  /* spent money within 30 days */
  /*******************************/
  SELECT *
  FROM
  (
    /*******************************/
    /* install_date before 30 days */
    /*******************************/
    SELECT *
    FROM
    (
      /*************************************************************************/
      /* long table (user_id, install_date, date, daily_spent, time_diff_days) */
      /*************************************************************************/
      SELECT *, DATEDIFF('DAY', install_date, date) AS time_diff_days
      FROM
      (
        /**************************************/
        /* long table (install_date, user_id) */
        /**************************************/
        SELECT DISTINCT user_id, date AS install_date
        FROM install
        WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
      )
      LEFT JOIN
      
      (
        /*******************************************/
        /* long table (date, user_id, daily_spent) */
        /*******************************************/
        SELECT date, user_id, SUM(converted) AS daily_spent
        FROM purchases_view
        WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
        GROUP BY date, user_id
        ORDER BY date, user_id
      )
      USING(user_id)
    )
    WHERE install_date <= (CURRENT_DATE - INTERVAL '30 DAY')
    
  )
  WHERE time_diff_days <= 30 OR time_diff_days IS NULL

)
GROUP BY install_date
ORDER BY install_date

