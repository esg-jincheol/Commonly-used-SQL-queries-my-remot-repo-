/***************************************************/
/* Summary table of MEDIAN time taken to level up */
/***************************************************/
SELECT type, new_level, MEDIAN(time_diff_minutes)::FLOAT/60 AS median_time_taken
FROM
(

  /************************************************/
  /* Stash, storage, dispensary upgrade time table */
  /************************************************/
  SELECT *
  FROM
  (
    /**********************/
    /* stash upgrade time */
    /**********************/
    SELECT *,  DATEDIFF('MINUTE', previous_level_upgrade_time, new_level_upgrade_time) AS time_diff_minutes
    FROM 
    (
      SELECT table_a.user_id, table_a.type, table_a.level AS user_level_before_upgrade, object_level_before_upgrade, previous_level_upgrade_time, table_b.level AS user_level_after_upgrade, new_level, new_level_upgrade_time
      FROM
      (
        /* user_id, level, type, object_level_before_upgrade, previous_level_upgrade_time */
        SELECT *
        FROM
        (
          /* stash level = 1 => the game start */
          SELECT DISTINCT user_id, level, type, new_level AS object_level_before_upgrade, timestamp AS previous_level_upgrade_time
          FROM upgrade
          WHERE type = 'stash'
          ORDER BY user_id, new_level 
        )
        UNION
          
        (
          SELECT user_id, 1 AS level, 'stash' AS type, 1 AS object_level_before_upgrade, MIN(timestamp) AS previous_level_upgrade_time
          FROM session_begin
          GROUP BY user_id
          ORDER BY user_id
        )
      ) AS table_a
      LEFT JOIN
      
      (
        SELECT DISTINCT user_id, level, type, new_level, timestamp AS new_level_upgrade_time
        FROM upgrade
        WHERE type = 'stash'
        ORDER BY user_id, new_level 
      ) AS table_b
      ON(table_a.user_id = table_b.user_id AND table_a.object_level_before_upgrade = table_b.new_level - 1 AND previous_level_upgrade_time < new_level_upgrade_time)
    )
    ORDER BY user_id, previous_level_upgrade_time
  )
  UNION 
  
  (
    /**********************/
    /* storage upgrade time */
    /**********************/
    SELECT *,  DATEDIFF('MINUTE', previous_level_upgrade_time, new_level_upgrade_time) AS time_diff_minutes
    FROM 
    (
      SELECT table_a.user_id, table_a.type, table_a.level AS user_level_before_upgrade, object_level_before_upgrade, previous_level_upgrade_time, table_b.level AS user_level_after_upgrade, new_level, new_level_upgrade_time
      FROM
      (
        /* user_id, level, type, object_level_before_upgrade, previous_level_upgrade_time */
        SELECT *
        FROM
        (
          /* storage level = 1 => the game start */
          SELECT DISTINCT user_id, level, type, new_level AS object_level_before_upgrade, timestamp AS previous_level_upgrade_time
          FROM upgrade
          WHERE type = 'storage'
          ORDER BY user_id, new_level 
        )
        UNION
          
        (
          SELECT user_id, 1 AS level, 'storage' AS type, 1 AS object_level_before_upgrade, MIN(timestamp) AS previous_level_upgrade_time
          FROM session_begin
          GROUP BY user_id
          ORDER BY user_id
        )
      ) AS table_a
      LEFT JOIN
      
      (
        SELECT DISTINCT user_id, level, type, new_level, timestamp AS new_level_upgrade_time
        FROM upgrade
        WHERE type = 'storage'
        ORDER BY user_id, new_level 
      ) AS table_b
      ON(table_a.user_id = table_b.user_id AND table_a.object_level_before_upgrade = table_b.new_level - 1 AND previous_level_upgrade_time < new_level_upgrade_time)
    )
    ORDER BY user_id, previous_level_upgrade_time
  )
  UNION 
  
  (
    /************************/
    /* storage upgrade time */
    /************************/
    SELECT *,  DATEDIFF('MINUTE', previous_level_upgrade_time, new_level_upgrade_time) AS time_diff_minutes
    FROM 
    (
      SELECT table_a.user_id, table_a.type, table_a.level AS user_level_before_upgrade, object_level_before_upgrade, previous_level_upgrade_time, table_b.level AS user_level_after_upgrade, new_level, new_level_upgrade_time
      FROM
      (
        /* user_id, level, type, object_level_before_upgrade, previous_level_upgrade_time */
        SELECT *
        FROM
        (
          /* storage level = 1 => the game start */
          SELECT DISTINCT user_id, level, type, new_level AS object_level_before_upgrade, timestamp AS previous_level_upgrade_time
          FROM upgrade
          WHERE type = 'dispensary'
          ORDER BY user_id, new_level 
        )
      ) AS table_a
      LEFT JOIN
      
      (
        SELECT DISTINCT user_id, level, type, new_level, timestamp AS new_level_upgrade_time
        FROM upgrade
        WHERE type = 'dispensary'
        ORDER BY user_id, new_level 
      ) AS table_b
      ON(table_a.user_id = table_b.user_id AND table_a.object_level_before_upgrade = table_b.new_level - 1 AND previous_level_upgrade_time < new_level_upgrade_time)
    )
    ORDER BY user_id, previous_level_upgrade_time
  )  

)
GROUP BY type, new_level
ORDER BY type, new_level
;
