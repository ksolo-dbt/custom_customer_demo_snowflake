with mart_count as (

    select count(*) as row_count
    from {{ ref('mart_wynn_resolved_player_worth') }}

),

answer_count as (

    select count(*) as row_count
    from {{ ref('stg_wynn_resolved_player_worth_answer_key') }}

)

select
    mart_count.row_count as mart_row_count,
    answer_count.row_count as answer_row_count
from mart_count
cross join answer_count
where mart_count.row_count != answer_count.row_count
