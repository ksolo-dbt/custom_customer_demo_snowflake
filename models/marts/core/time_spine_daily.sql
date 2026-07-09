{{
    config(
        materialized = 'table',
    )
}}

with generated_dates as (

    select
        dateadd(day, seq4(), dateadd(year, -5, current_date()))::date as date_day
    from table(generator(rowcount => 3000))

)

select date_day
from generated_dates
where date_day < dateadd(year, 2, current_date())
