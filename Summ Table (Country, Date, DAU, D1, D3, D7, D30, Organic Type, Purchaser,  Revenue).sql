/*********************************************************************************************************************************************************************************************************************/
/* summary table (date, country_category, user_type, user_country, dau, revenue, daily_paying_users, install_count, d1_session_begin_count, d3_session_begin_count, d7_session_begin_count, d30_session_begin_count) */
/*********************************************************************************************************************************************************************************************************************/
SELECT *
FROM
(

  /*****************************************************************************************************/
  /* summary table (date, user_type, user_country, country_category, dau, revenue, daily_paying_users) */
  /*****************************************************************************************************/
  SELECT *,
      CASE
        WHEN user_country = 'US' THEN 'US'
        WHEN user_country = 'CA' THEN 'CA'
        ELSE 'Others'
      END AS country_category
  FROM
  (
    /***********************************************************************************/
    /* summary table (date, user_type, user_country, dau, revenue, daily_paying_users) */
    /***********************************************************************************/
    SELECT date, user_type, user_country, COUNT(DISTINCT user_id) AS dau, SUM(individual_spent) AS revenue, SUM(paying_user_indicator) AS daily_paying_users
    FROM
    (
      /*******************************************************************************************/
      /* long table (date, user_id, user_type, user_country, individual_spent, paying_user_indicator) */
      /*******************************************************************************************/
      SELECT *, CASE WHEN individual_spent > 0 THEN 1 ELSE 0 END AS paying_user_indicator
      FROM
      (
        /*******************************************************/
        /* long table (date, user_id, user_type, user_country) */
        /*******************************************************/
        SELECT *
        FROM
        (
          SELECT DISTINCT date, user_id
          FROM session_begin
          WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
        )
        LEFT JOIN
        
        (
          /**************************************/
          /* long table (user_id, user_country) */
          /**************************************/
          SELECT user_id, MAX(country) AS user_country
          FROM user_country
          GROUP BY user_id
        )
        USING(user_id)
        
        LEFT JOIN
        (
          /***************************************************************/
          /* long table (user_id, user_type (organic or not) ) - filtered  */
          /***************************************************************/
          SELECT user_id, 
                          CASE 
                            WHEN type LIKE '%rganic%' THEN 'organic'
                            WHEN source LIKE '%rganic%' THEN 'organic'
                            /*WHEN type LIKE 'new' THEN 'new'*/
                            WHEN type = '' THEN 'unknown'
                            ELSE 'paid'
                          END AS user_type
          FROM
          (
            /************************************/
            /* consider the last timestamp data */
            /************************************/
            SELECT *
            FROM         
            (
              SELECT user_id, MAX(date) AS date, MAX(timestamp) AS timestamp
              FROM install
              GROUP BY user_id
            )
            LEFT JOIN
            
            (
              SELECT user_id, type, source, date, timestamp
              FROM install
            )
            USING(user_id, date, timestamp)
          )
        )
        USING(user_id)

      )
      LEFT JOIN
        
      (
        /************************************************/
        /* long table (date, user_id, individual_spent) */
        /************************************************/
        SELECT date, user_id, SUM(converted) AS individual_spent
        FROM purchases_view
        WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
        GROUP BY date, user_id
        ORDER BY date, user_id
      )
      USING(date, user_id)
    
    )
    GROUP BY date, user_type, user_country
    ORDER BY date, user_type, user_country
  )
  

)
LEFT JOIN

(
  /*************/
  /* Retention */
  /*************/
  /* summary table (user_country, user_type, date, d1_session_begin_count, install_count) */
 
  SELECT user_country, user_type, install_date AS date, COUNT(install_date) AS install_count,
         COUNT(d1_session_begin_date)::FLOAT AS d1_session_begin_count,
         COUNT(d3_session_begin_date)::FLOAT AS d3_session_begin_count,
         COUNT(d7_session_begin_date)::FLOAT AS d7_session_begin_count,
         COUNT(d30_session_begin_date)::FLOAT AS d30_session_begin_count
  FROM
  (
    /***********************************************************************************/
    /* long table (user_id, install_date, user_type, user_country, session_begin_date) */
    /***********************************************************************************/
    SELECT *
    FROM
    (      
        /***************************************************************/
        /* long table (user_id, install_date, user_type, user_country) */
        /***************************************************************/
        SELECT *
        FROM
        (
          /***************************************************************/
          /* long table (user_id, user_type (organic or not) ) - filtered  */
          /***************************************************************/
          SELECT user_id, date AS install_date,
                          CASE 
                            WHEN type LIKE '%rganic%' THEN 'organic'
                            WHEN source LIKE '%rganic%' THEN 'organic'
                            /*WHEN type LIKE 'new' THEN 'new'*/
                            WHEN type = '' THEN 'unknown'
                            ELSE 'paid'
                          END AS user_type
          FROM
          (
            /************************************/
            /* consider the last timestamp data */
            /************************************/
            SELECT *
            FROM         
            (
              SELECT user_id, MAX(date) AS date, MAX(timestamp) AS timestamp
              FROM install
              WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
              GROUP BY user_id
            )
            LEFT JOIN
            
            (
              SELECT user_id, type, source, date, timestamp
              FROM install
              WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
            )
            USING(user_id, date, timestamp)
          )
        )
        LEFT JOIN
          
        (
          /**************************************/
          /* long table (user_id, user_country) */
          /**************************************/
          SELECT user_id, MAX(country) AS user_country
          FROM user_country
          GROUP BY user_id
        )
        USING(user_id)
    ) AS install_table
    LEFT JOIN
    (
      /**********************************************/
      /* D1 Retention : user_id, session_begin_date */
      /**********************************************/
      SELECT DISTINCT user_ID, date AS d1_session_begin_date
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
    ) AS d1_session_begin_table
    ON(install_table.user_ID = d1_session_begin_table.user_ID AND install_table.install_date = d1_session_begin_table.d1_session_begin_date - 1)

    LEFT JOIN
    (
      /**********************************************/
      /* D3 Retention : user_id, session_begin_date */
      /**********************************************/
      SELECT DISTINCT user_ID, date AS d3_session_begin_date
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
    ) AS d3_session_begin_table
    ON(install_table.user_ID = d3_session_begin_table.user_ID AND install_table.install_date = d3_session_begin_table.d3_session_begin_date - 3)

    LEFT JOIN
    (
      /**********************************************/
      /* D7 Retention : user_id, session_begin_date */
      /**********************************************/
      SELECT DISTINCT user_ID, date AS d7_session_begin_date
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
    ) AS d7_session_begin_table
    ON(install_table.user_ID = d7_session_begin_table.user_ID AND install_table.install_date = d7_session_begin_table.d7_session_begin_date - 7)

    LEFT JOIN
    (
      /***********************************************/
      /* D30 Retention : user_id, session_begin_date */
      /***********************************************/
      SELECT DISTINCT user_ID, date AS d30_session_begin_date
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '2 MONTH') AND (CURRENT_DATE -1)
    ) AS d30_session_begin_table
    ON(install_table.user_ID = d30_session_begin_table.user_ID AND install_table.install_date = d30_session_begin_table.d30_session_begin_date - 30)
    
    LEFT JOIN
    (
      SELECT DISTINCT user_ID, date AS same_date_session_begin
      FROM session_begin
      WHERE date > (CURRENT_DATE - INTERVAL '1 MONTH')
    ) AS same_date_session_begin_table
    ON(install_table.user_ID = same_date_session_begin_table.user_ID AND install_table.install_date = same_date_session_begin_table.same_date_session_begin - 0) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
  
  )
  WHERE same_date_session_begin IS NOT NULL
  GROUP BY user_country, user_type, date
)
USING(date, user_country, user_type)



