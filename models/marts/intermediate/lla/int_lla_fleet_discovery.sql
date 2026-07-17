with fleet_base as (

    select * from {{ ref('int_lla_fleet_base') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by account_id
            order by dt desc
        ) as account_record_rank
    from fleet_base
    where service_status = 'Active'

)

select
    account_id,
    cm_mac,
    msisdn,
    imsi,
    imei,
    manufacturer,
    device_model,
    broadband_plan_name,
    service_status,
    country,
    dt as latest_service_dt
from ranked
where account_record_rank = 1
