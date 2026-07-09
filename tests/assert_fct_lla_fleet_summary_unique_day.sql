select
    account_id,
    cm_mac,
    dt,
    count(*) as row_count
from {{ ref('fct_lla_fleet_summary') }}
group by 1, 2, 3
having count(*) > 1
