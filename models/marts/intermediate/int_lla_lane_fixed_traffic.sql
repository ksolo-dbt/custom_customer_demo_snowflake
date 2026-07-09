with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

data_day_facts as (

    select * from {{ ref('stg_lla_cm_data_day_facts') }}

),

joined as (

    select
        fleet.account_id,
        fleet.cm_mac,
        fleet.msisdn,
        fleet.imsi,
        fleet.imei,
        fleet.manufacturer,
        fleet.device_model,
        data_day_facts.dt,
        cast(data_day_facts.date_key as timestamp_ntz) as event_time,
        'fixed_traffic' as lane,
        data_day_facts.avg_speed_down_kbps as fixed_kbps_down,
        data_day_facts.avg_speed_up_kbps as fixed_kbps_up,
        data_day_facts.total_bytes_down_kb as fixed_kb_down,
        data_day_facts.total_bytes_up_kb as fixed_kb_up
    from data_day_facts
    inner join fleet
        on data_day_facts.cm_mac = fleet.cm_mac

)

select * from joined
