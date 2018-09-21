/***************************************************************************************/
/* This query generate a table that has columns listed below over the past one month.  */
/* first, connect to the ESG server                                                    */
/***************************************************************************************/
 
/**********************/
/*  list of columns   */
/**********************/
/* date               */ 
/* game               */
/* daily_revenue      */
/* daily_impressions  */
/* source             */
/* game_name          */
/**********************/
SELECT *, CASE 
              WHEN game = 'potfarm' THEN 'PFGR' 
              WHEN game = 'pfmobile' THEN 'PFGR'
              WHEN game = 'budfarm' THEN 'BFGR' 
              ELSE game
            END AS game_name
FROM
(
  /* daily revenue and impression */
  SELECT *
  FROM
  (
    /* vungle */
    SELECT date, game, SUM(revenue) AS daily_revenue, SUM(impressions) AS daily_impressions, 'vungle' AS source
    FROM
    (
      SELECT date, game, impressions, revenue, platform
      FROM vungle
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '1 MONTH') AND (CURRENT_DATE - 1) /* over the past one month */
    )
    GROUP BY date, game
    ORDER BY date, game
  )
  UNION
  
  (
    /* chartboost */
    SELECT date, game, SUM(revenue) AS daily_revenue, SUM(impressions_delivered) AS daily_impressions, 'chartboost' AS source
    FROM
    (
      SELECT date, game, impressions_delivered, revenue, platform
      FROM chartboost
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '1 MONTH') AND (CURRENT_DATE - 1) /* over the past one month */
    )
    GROUP BY date, game
    ORDER BY date, game
  )
  UNION
  
  (
    /* tapresearch */
    SELECT date, game, SUM(revenue) AS daily_revenue, SUM(impressions) AS daily_impressions, 'tapresearch' AS source
    FROM
    (
      SELECT date, game, impressions, revenue, placement
      FROM tapresearch
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '1 MONTH') AND (CURRENT_DATE - 1) /* over the past one month */
    )
    GROUP BY date, game
    ORDER BY date, game
  )
  UNION
  
  (
    /* trial_pay_campaign_summary */
    SELECT date, game, SUM(gross_revenue_usd) AS daily_revenue, SUM(trialpay_impressions) AS daily_impressions, 'trial_pay_campaign_summary' AS source
    FROM
    (
      SELECT date, game, trialpay_impressions, gross_revenue_usd
      FROM trial_pay_campaign_summary
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '1 MONTH') AND (CURRENT_DATE - 1) /* over the past one month */
    )
    GROUP BY date, game
    ORDER BY date, game
  )
)
ORDER BY date
;
