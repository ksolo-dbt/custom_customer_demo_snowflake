with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

status_facts as (

    select * from {{ ref('stg_lla_cm_status_facts') }}

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
        status_facts.dt,
        status_facts.poll_time as event_time,
        'broadband' as lane,
        iff(status_facts.cm_status = 'online', 1, 0) as bb_is_online,
        iff(
            status_facts.cm_status = 'offline'
            and coalesce(
                lag(status_facts.cm_status) over (
                    partition by status_facts.cm_mac
                    order by status_facts.poll_time
                ),
                'online'
            ) = 'online',
            1,
            0
        ) as bb_interrupt_segment,
        0.25 as bb_est_duration_15min
    from status_facts
    inner join fleet
        on status_facts.cm_mac = fleet.cm_mac

)

select * from joined
