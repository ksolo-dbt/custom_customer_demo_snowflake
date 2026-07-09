with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

rf_facts as (

    select * from {{ ref('stg_lla_cm_rf_facts') }}

),

with_reboot_flags as (

    select
        rf_facts.*,
        iff(
            rf_facts.uptime_seconds
            < lag(rf_facts.uptime_seconds) over (
                partition by rf_facts.cm_mac
                order by rf_facts.poll_time
            ),
            1,
            0
        ) as cm_is_reboot
    from rf_facts

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
        with_reboot_flags.dt,
        with_reboot_flags.poll_time as event_time,
        'cm_uptime' as lane,
        with_reboot_flags.uptime_seconds / 3600.0 as cm_uptime_hours,
        with_reboot_flags.cm_is_reboot,
        with_reboot_flags.t3_timeouts as cm_t3_avg,
        with_reboot_flags.ds_snr_db as cm_snr_avg_down
    from with_reboot_flags
    inner join fleet
        on with_reboot_flags.cm_mac = fleet.cm_mac

)

select * from joined
