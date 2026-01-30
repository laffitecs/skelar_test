with a as (select us1.id_user,action,
                  date(date_action) date                                                              ,
                      DATETIME_DIFF(
      LEAD(date_action) OVER (PARTITION BY id_user ORDER BY date_action),
      date_action,
      MINUTE
    ) / 60.0 as total
           from user_sessions us1
           WHERE date_action >= DATE_SUB(CURRENT_DATE(), INTERVAL 10 DAY)

           )

select id_user, date, sum (total)
from a
where action = 'open'
group by 1, 2
order by 1