select
    resolved_player_id,
    count(*) as row_count
from {{ ref('mart_wynn_resolved_player_worth') }}
group by 1
having count(*) > 1
