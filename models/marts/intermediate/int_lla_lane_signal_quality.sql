with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

rf_facts as (

    select * from {{ ref('stg_lla_cm_rf_facts') }}

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
        rf_facts.dt,
        rf_facts.poll_time as event_time,
        'signal_quality' as lane,
        rf_facts.ds_snr_db as cm_snr_avg_down,
        rf_facts.ds_power_dbmv::varchar as signal_rsrq_db,
        rf_facts.us_power_dbmv::varchar as signal_rsrp_dbm
    from rf_facts
    inner join fleet
        on rf_facts.cm_mac = fleet.cm_mac

)

select * from joined
