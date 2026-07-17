with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

mobile_sessions as (

    select * from {{ ref('stg_lla_mobile_data_xdr') }}

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
        mobile_sessions.dt,
        mobile_sessions.start_time as event_time,
        'mobile_cdr' as lane,
        mobile_sessions.volume_downlink_bytes as mobile_dl_bytes,
        mobile_sessions.volume_uplink_bytes as mobile_ul_bytes,
        iff(
            mobile_sessions.duration_seconds > 0,
            (
                mobile_sessions.volume_downlink_bytes
                + mobile_sessions.volume_uplink_bytes
            ) * 8.0 / mobile_sessions.duration_seconds / 1000000,
            null
        ) as mobile_traffic_mbps,
        mobile_sessions.apn as mobile_apn,
        mobile_sessions.duration_seconds / 60.0 as mobile_duration_min,
        mobile_sessions.rat_type as mobile_network_type,
        mobile_sessions.cell_id as mobile_cell_cdr
    from mobile_sessions
    inner join fleet
        on mobile_sessions.imei = fleet.imei
        and mobile_sessions.msisdn = fleet.msisdn

)

select * from joined
