select
    account_id,
    count(*) as row_count
from {{ ref('int_lla_fleet_discovery') }}
group by 1
having count(*) > 1
