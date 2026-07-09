with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

reboots as (

    select * from {{ ref('stg_lla_plume_reboot_fact') }}

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
        reboots.dt,
        reboots.reboot_time as event_time,
        'reboots' as lane,
        reboots.reboot_reason as reboot_type,
        'plume' as reboot_source
    from reboots
    inner join fleet
        on reboots.cm_mac = fleet.cm_mac

)

select * from joined
