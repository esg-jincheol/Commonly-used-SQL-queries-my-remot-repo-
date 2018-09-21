/*************************************************************************/
/* BF420 stash/storage/dispensary upgrade time (type level distribution) */
/*************************************************************************/
SELECT *
FROM
(
  SELECT *
  FROM
  (
    SELECT *
    FROM
    (
      SELECT user_id, MAX(level) AS current_level
      FROM session_begin
      GROUP BY user_id
    )
    LEFT JOIN
  
    (
      SELECT user_id, type, MAX(new_level) AS current_type_level
      FROM upgrade
      WHERE type = 'stash' OR type = 'storage' OR type = 'dispensary'
      GROUP BY user_id, type
    )
    USING(user_id)
  )
  WHERE type IS NOT NULL
)
LEFT JOIN

(
  SELECT user_id, MAX(date) AS final_install
  FROM install
  WHERE date >= '2017-01-01'
  GROUP BY user_id
)
USING(user_id)
;


