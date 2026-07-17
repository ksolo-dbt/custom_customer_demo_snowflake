select
    player_trip_id,
    count(*) as row_count
from {{ ref('fct_wynn_player_trips') }}
group by 1
having count(*) > 1
