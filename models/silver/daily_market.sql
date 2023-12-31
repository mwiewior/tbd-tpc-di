with
    s1 as (
        select
            -- dm_date,
            min(dm_low) over (
                partition by dm_s_symb
                order by dm_date asc
                rows between 364 preceding and 0 following  -- CURRENT ROW
            ) fifty_two_week_low,
            max(dm_high) over (
                partition by dm_s_symb
                order by dm_date asc
                rows between 364 preceding and 0 following  -- CURRENT ROW
            ) fifty_two_week_high,
            *
        from {{ ref("brokerage_daily_market") }}
    ),
    s2 as (
        select a.*, 
               b.dm_date as fifty_two_week_low_date, 
               c.dm_date as fifty_two_week_high_date
        from s1 a
        join
            s1 b
            on a.dm_s_symb = b.dm_s_symb
            and a.fifty_two_week_low = b.dm_low
            and b.dm_date <= a.dm_date
        join
            s1 c
            on a.dm_s_symb = c.dm_s_symb
            and a.fifty_two_week_high = c.dm_high
            and c.dm_date <= a.dm_date
    )

SELECT * FROM (
  SELECT *, row_number() over (
        partition by dm_s_symb, dm_date
        order by fifty_two_week_low_date, fifty_two_week_high_date
    )rank FROM s2) tmp WHERE rank = 1