/***************************************************************************************************/
/*   Generate a table that information on metrices listed as follows;
/* user_type : organic, or paid
/* date
/* Daily Active Users (DAU)                                            */
/* Revenue
/* purchase_user : conversion = purchase_user/dau

/* Average Revenue Per Daily Active User (ARPDAU)
/* Day 1 Retention (D1)                              */
/***************************************************************************************************/

/***************************************************************************************/
/* This query generate a table that has columns listed below over the past one month.  */
/* first, connect to the ESG server                                                    */
/***************************************************************************************/


WbVarDef date_period = '2018-08-01';

/*************************/
/*                       */
/*                       */
/* Adding country column */
/*                       */
/*                       */
/*************************/
SELECT user_type, date, SUM(dau) AS DAU, SUM(revenue) AS revenue, SUM(purchase_user) AS purchase_user, SUM(d1_session_begin_count) AS d1_session_begin_count, SUM(d1_install_count) AS d1_install_count,
       SUM(d3_session_begin_count) AS d3_session_begin_count, SUM(d3_install_count) AS d3_install_count, SUM(d7_session_begin_count) AS d7_session_begin_count, SUM(d7_install_count) AS d7_install_count,
        SUM(d30_session_begin_count) AS d30_session_begin_count, SUM(d30_install_count) AS d30_install_count
FROM

(
SELECT *
FROM

(
  /*******/
  /* DAU */
  /*******/
  /* compute DAU */
  SELECT country, user_type, date, count(DISTINCT user_id) AS dau
  FROM
  (
    (
      /* distinguish 'organic' and 'paid' installs */
      SELECT user_id, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
      FROM
      (
        /* exclude type = 'new' and '' */
        SELECT *
        FROM install
        WHERE not type = 'new' AND
              not type = ''
      )
    )
    LEFT JOIN
    session_begin
    USING(user_id)
  )
  WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  GROUP BY country, user_type, date
  ORDER BY country, user_type, date
)
LEFT JOIN

(
  /***********/
  /* Revenue */
  /***********/
  /* compute revenue */
  SELECT country, user_type, date, SUM(converted) AS revenue
  FROM
  (
    (
      /* distinguish 'organic' and 'paid' installs */
      SELECT user_id, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
      FROM
      (
        /* exclude type = 'new' and '' */
        SELECT *
        FROM install
        WHERE not type = 'new' AND
              not type = ''
      )
    )
    LEFT JOIN
    purchases_view
    USING(user_id)
  )
  WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  GROUP BY country, user_type, date
  ORDER BY country, user_type, date
)
USING(country, user_type, date)

LEFT JOIN
(
  /********************************/
  /* purchase user for Conversion */
  /********************************/
  SELECT country, user_type, date,  COUNT(DISTINCT user_id) AS purchase_user
  FROM
  (
      (
      /* distinguish 'organic' and 'paid' installs */
      SELECT user_id, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
      FROM
      (
        /* exclude type = 'new' and '' */
        SELECT *
        FROM install
        WHERE not type = 'new' AND
              not type = ''
      )
    )
    LEFT JOIN
    purchases_view
    USING(user_id)
  )
  WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  GROUP BY country, user_type, date
  ORDER BY country, user_type, date
)
USING(country, user_type, date)

LEFT JOIN
(
  /*********************************************************************************************************************/
  /* 'D1_session_begin_count' and 'D1_install_count' for 'D1 Retention' (='D1_session_begin_count'/'D1_install_count') */
  /*********************************************************************************************************************/
  SELECT country, user_type, install_date AS date, COUNT(session_begin_date)::FLOAT AS D1_session_begin_count, COUNT(install_date) AS D1_install_count
  FROM
  (
    /* distinguish 'organic' and 'paid' installs */
    SELECT DISTINCT user_id, date AS install_date, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
    FROM
    (
      /* exclude type = 'new' and '' */
      SELECT *
      FROM install
      WHERE not type = 'new' AND
            not type = ''
    )
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS install_filtered
  LEFT JOIN
  (
    SELECT DISTINCT user_ID, date AS session_begin_date
    FROM session_begin
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS session_begin_filtered
  ON(install_filtered.user_ID = session_begin_filtered.user_ID AND install_filtered.install_date = session_begin_filtered.session_begin_date - 1) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
  GROUP BY country, user_type, install_date
  ORDER BY country, user_type, install_date
)
USING(country, user_type, date)

LEFT JOIN
(
  /*********************************************************************************************************************/
  /* 'D3_session_begin_count' and 'D3_install_count' for 'D3 Retention' (='D3_session_begin_count'/'D3_install_count') */
  /*********************************************************************************************************************/
  SELECT country, user_type, install_date AS date, COUNT(session_begin_date)::FLOAT AS D3_session_begin_count, COUNT(install_date) AS D3_install_count
  FROM
  (
    /* distinguish 'organic' and 'paid' installs */
    SELECT DISTINCT user_id, date AS install_date, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
    FROM
    (
      /* exclude type = 'new' and '' */
      SELECT *
      FROM install
      WHERE not type = 'new' AND
            not type = ''
    )
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS install_filtered
  LEFT JOIN
  (
    SELECT DISTINCT user_ID, date AS session_begin_date
    FROM session_begin
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS session_begin_filtered
  ON(install_filtered.user_ID = session_begin_filtered.user_ID AND install_filtered.install_date = session_begin_filtered.session_begin_date - 3) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
  GROUP BY country, user_type, install_date
  ORDER BY country, user_type, install_date
)
USING(country, user_type, date)

LEFT JOIN
(
  /*********************************************************************************************************************/
  /* 'D7_session_begin_count' and 'D7_install_count' for 'D7 Retention' (='D7_session_begin_count'/'D7_install_count') */
  /*********************************************************************************************************************/
  SELECT country, user_type, install_date AS date, COUNT(session_begin_date)::FLOAT AS D7_session_begin_count, COUNT(install_date) AS D7_install_count
  FROM
  (
    /* distinguish 'organic' and 'paid' installs */
    SELECT DISTINCT user_id, date AS install_date, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
    FROM
    (
      /* exclude type = 'new' and '' */
      SELECT *
      FROM install
      WHERE not type = 'new' AND
            not type = ''
    )
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS install_filtered
  LEFT JOIN
  (
    SELECT DISTINCT user_ID, date AS session_begin_date
    FROM session_begin
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS session_begin_filtered
  ON(install_filtered.user_ID = session_begin_filtered.user_ID AND install_filtered.install_date = session_begin_filtered.session_begin_date - 7) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
  GROUP BY country, user_type, install_date
  ORDER BY country, user_type, install_date
)
USING(country, user_type, date)

LEFT JOIN
(
  /*********************************************************************************************************************/
  /* 'D30_session_begin_count' and 'D30_install_count' for 'D30 Retention' (='D7_session_begin_count'/'D7_install_count') */
  /*********************************************************************************************************************/
  SELECT country, user_type, install_date AS date, COUNT(session_begin_date)::FLOAT AS D30_session_begin_count, COUNT(install_date) AS D30_install_count
  FROM
  (
    /* distinguish 'organic' and 'paid' installs */
    SELECT DISTINCT user_id, date AS install_date, CASE WHEN type LIKE '%rganic' THEN 'organic' ELSE 'paid' END AS user_type, CASE WHEN user_id IN (SELECT DISTINCT user_id FROM user_data WHERE country = 'US') THEN 'US' ELSE 'others' END AS country
    FROM
    (
      /* exclude type = 'new' and '' */
      SELECT *
      FROM install
      WHERE not type = 'new' AND
            not type = ''
    )
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS install_filtered
  LEFT JOIN
  (
    SELECT DISTINCT user_ID, date AS session_begin_date
    FROM session_begin
    WHERE date BETWEEN '2018-01-01' AND (CURRENT_DATE - 1)
  ) AS session_begin_filtered
  ON(install_filtered.user_ID = session_begin_filtered.user_ID AND install_filtered.install_date = session_begin_filtered.session_begin_date - 30) /* change the substracting value to obtain a different day retention (ex. Day 2, Day 3) */
  GROUP BY country, user_type, install_date
  ORDER BY country, user_type, install_date
)
USING(country, user_type, date)
ORDER BY country, user_type, date

)
GROUP BY user_type, date
ORDER BY user_type, date
;


