SELECT SUM(time_diff_seconds)
FROM
(
/*************************************/
/*BF420 grow op time to level up v.1 */
/*************************************/
/* grow op */
SELECT *
FROM
(
  SELECT old_level_table.user_id, old_level_table.level, old_level_table.type, old_level_table.plot, old_level, old_level_timestamp, next_level, next_level_timestamp, DATEDIFF('SECOND', old_level_timestamp, next_level_timestamp) AS time_diff_seconds
  FROM
  (
    SELECT user_id, level, type, plot, new_level AS old_level, timestamp AS old_level_timestamp
    FROM
    (
      /* pick specific types */
      SELECT user_id, level, type, plot, new_level, timestamp
      FROM upgrade 
      WHERE (type = 'waterPump' OR type = 'growLight') AND user_id IN (SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)) 
      ORDER BY plot, new_level
    )

    UNION
    (
      /*  get growLight level 1 timestamp */
      SELECT user_id, level, 'growLight' AS type, RANK() OVER(PARTITION BY user_id ORDER BY timestamp) - 1 AS plot, 1 AS new_level, timestamp
      FROM
      (
        SELECT *
        FROM
        (
          SELECT user_id, level, source, subsource, timestamp
          FROM coins_out
          WHERE source = 'upgrade' AND user_id IN (/* take into account only recent users */ SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1))
        )
        UNION
        (  
          /* the very first pot is given at the very beginning time */
          SELECT user_id, 1 AS level, 'upgrade' AS source, 'plot_0' AS subsource, MIN(timestamp) AS timestamp
          FROM session_begin
          WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
          GROUP BY user_id
        )
      )
      WHERE subsource = 'plot_0'
    )
    
    UNION
    (
      /*  get growLight level 1 timestamp */
      SELECT user_id, level, 'waterPump' AS type, RANK() OVER(PARTITION BY user_id ORDER BY timestamp) - 1 AS plot, 1 AS new_level, timestamp
      FROM
      (
        SELECT *
        FROM
        (
          SELECT user_id, level, source, subsource, timestamp
          FROM coins_out
          WHERE source = 'upgrade' AND user_id IN (/* take into account only recent users */ SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1))
        )
        UNION
        (  
          SELECT user_id, 1 AS level, 'upgrade' AS source, 'plot_0' AS subsource, MIN(timestamp) AS timestamp
          FROM session_begin
          WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
          GROUP BY user_id
        )
      )
      WHERE subsource = 'plot_0'
    )
    ORDER BY user_id, type, plot, old_level
  ) AS old_level_table
  LEFT JOIN
  
  (
    SELECT user_id, level, type, plot, new_level AS next_level, timestamp AS next_level_timestamp
    FROM
    (
      SELECT *
      FROM
      (
        /* pick specific types */
        SELECT user_id, level, type, plot, new_level, timestamp
        FROM upgrade 
        WHERE (type = 'waterPump' OR type = 'growLight') AND user_id IN (/* take into account only recent users */  SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)) 
        ORDER BY plot, new_level
      )
    
      UNION
      (
        /*  get growLight level 1 timestamp */
        SELECT user_id, level, 'growLight' AS type, RANK() OVER(PARTITION BY user_id ORDER BY timestamp) - 1 AS plot, 1 AS new_level, timestamp
        FROM
        (
          SELECT *
          FROM
          (
            SELECT user_id, level, source, subsource, timestamp
            FROM coins_out
            WHERE source = 'upgrade' AND user_id IN (/* take into account only recent users */ SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1))
          )
          UNION
          (  
            /* the very first pot is given at the very beginning time */
            SELECT user_id, 1 AS level, 'upgrade' AS source, 'plot_0' AS subsource, MIN(timestamp) AS timestamp
            FROM session_begin
            WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
            GROUP BY user_id
          )
        )
        WHERE subsource = 'plot_0'
      )
      
      UNION
      (
        /*  get growLight level 1 timestamp */
        SELECT user_id, level, 'waterPump' AS type, RANK() OVER(PARTITION BY user_id ORDER BY timestamp) - 1 AS plot, 1 AS new_level, timestamp
        FROM
        (
          SELECT *
          FROM
          (
            SELECT user_id, level, source, subsource, timestamp
            FROM coins_out
            WHERE source = 'upgrade' AND user_id IN (/* take into account only recent users */ SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1))
          )
          UNION
          (  
            SELECT user_id, 1 AS level, 'upgrade' AS source, 'plot_0' AS subsource, MIN(timestamp) AS timestamp
            FROM session_begin
            WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
            GROUP BY user_id
          )
        )
        WHERE subsource = 'plot_0'
      )
    )
    ORDER BY user_id, type, plot, next_level
  ) AS new_level_table
  ON(old_level_table.user_id = new_level_table.user_id AND old_level_table.type = new_level_table.type AND old_level_table.plot = new_level_table.plot AND old_level_table.old_level = new_level_table.next_level - 1)

)
WHERE time_diff_seconds > 0 OR time_diff_seconds IS NULL
)
WHERE time_diff_seconds>0 AND old_level >1


/**********************************/
/* BF420 time to obtain more pots */
/**********************************/
SELECT *
FROM
(
  SELECT user_id, level, source, subsource, RANK() OVER(PARTITION BY user_id ORDER BY timestamp), timestamp
  FROM
  (
    SELECT *
    FROM
    (
      SELECT user_id, level, source, subsource, timestamp
      FROM coins_out
      WHERE source = 'upgrade' AND user_id IN (/* take into account only recent users */ SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1))
    )
    UNION
    (  
      SELECT user_id, 1 AS level, 'upgrade' AS source, 'plot_0' AS subsource, MIN(timestamp) AS timestamp
      FROM session_begin
      WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)
      GROUP BY user_id
    )
  )
  WHERE subsource = 'plot_0'
)
WHERE user_id = 26229


/**************************************/
/* BF420 grow op time to level up v.2 */
/**************************************/
SELECT SUM(time_diff_seconds)
FROM
(
  SELECT table_a.user_id, table_a.level, table_a.type, table_a.plot, old_level, old_level_timestamp, next_level, next_level_timestamp, DATEDIFF('SECOND', old_level_timestamp, next_level_timestamp) AS time_diff_seconds
  FROM
  (
    /* pick specific types */
    SELECT user_id, level, type, plot, new_level AS old_level, timestamp AS old_level_timestamp
    FROM upgrade 
    WHERE (type = 'waterPump' OR type = 'growLight') AND user_id IN (/* take into account only recent users */  SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)) 
    ORDER BY plot, new_level
  ) AS table_a
  LEFT JOIN
  
  (
    /* pick specific types */
    SELECT user_id, level, type, plot, new_level AS next_level, timestamp AS next_level_timestamp
    FROM upgrade 
    WHERE (type = 'waterPump' OR type = 'growLight') AND user_id IN (/* take into account only recent users */  SELECT DISTINCT user_id FROM install WHERE date BETWEEN (CURRENT_DATE - INTERVAL '3 MONTH') AND (CURRENT_DATE -1)) 
    ORDER BY plot, new_level
  ) AS table_b
  ON(table_a.user_id = table_b.user_id AND table_a.type = table_b.type AND table_a.plot = table_b.plot AND table_a.old_level = table_b.next_level - 1)
)
WHERE time_diff_seconds>0


22034297288
22194150397
