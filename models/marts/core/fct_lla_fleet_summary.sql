with fleet as (

    select * from {{ ref('int_lla_fleet_discovery') }}

),

device_dates as (

    select distinct account_id, cm_mac, dt
    from {{ ref('fct_lla_fleet_timeline') }}

),

broadband_daily as (

    select
        account_id,
        cm_mac,
        dt,
        count(*) as bb_polls_total,
        sum(bb_is_online) as bb_polls_online,
        sum(iff(bb_is_online = 1, bb_est_duration_15min, 0)) as bb_hours_online,
        sum(iff(bb_is_online = 0, bb_est_duration_15min, 0)) as bb_hours_offline,
        count_if(bb_interrupt_segment = 1) as bb_interrupts
    from {{ ref('int_lla_lane_broadband') }}
    group by 1, 2, 3

),

cm_uptime_daily as (

    select
        account_id,
        cm_mac,
        dt,
        max(cm_uptime_hours) as cm_uptime_hours,
        sum(cm_is_reboot) as cm_reboots,
        avg(cm_snr_avg_down) as cm_snr_avg_down
    from {{ ref('int_lla_lane_cm_uptime') }}
    group by 1, 2, 3

),

fixed_traffic_daily as (

    select
        account_id,
        cm_mac,
        dt,
        sum(fixed_kb_down) as fixed_kb_down,
        sum(fixed_kb_up) as fixed_kb_up,
        avg(fixed_kbps_down) as fixed_avg_kbps_down,
        avg(fixed_kbps_up) as fixed_avg_kbps_up
    from {{ ref('int_lla_lane_fixed_traffic') }}
    group by 1, 2, 3

),

mobile_daily as (

    select
        account_id,
        cm_mac,
        dt,
        count(*) as mobile_sessions,
        sum(mobile_dl_bytes) / 1024.0 / 1024.0 as mobile_dl_mb,
        sum(mobile_ul_bytes) / 1024.0 / 1024.0 as mobile_ul_mb
    from {{ ref('int_lla_lane_mobile_cdr') }}
    group by 1, 2, 3

),

plume_daily as (

    select
        account_id,
        cm_mac,
        dt,
        count(*) as plume_reboots
    from {{ ref('int_lla_lane_reboots') }}
    group by 1, 2, 3

),

signal_daily as (

    select
        account_id,
        cm_mac,
        dt,
        avg(cm_snr_avg_down) as signal_avg_snr_down_db,
        avg(try_to_number(signal_rsrq_db, 10, 2)) as signal_avg_power_down_dbmv
    from {{ ref('int_lla_lane_signal_quality') }}
    group by 1, 2, 3

),

dna_daily as (

    select
        account_id,
        cm_mac,
        dt,
        count(*) as dna_changes
    from {{ ref('int_lla_lane_dna_changes') }}
    group by 1, 2, 3

),

joined as (

    select
        device_dates.account_id,
        device_dates.cm_mac,
        fleet.msisdn,
        fleet.imei,
        fleet.manufacturer,
        fleet.device_model,
        device_dates.dt,
        coalesce(broadband_daily.bb_polls_total, 0) as bb_polls_total,
        coalesce(broadband_daily.bb_polls_online, 0) as bb_polls_online,
        coalesce(broadband_daily.bb_hours_online, 0) as bb_hours_online,
        coalesce(broadband_daily.bb_hours_offline, 0) as bb_hours_offline,
        iff(
            broadband_daily.bb_polls_total > 0,
            broadband_daily.bb_polls_online / broadband_daily.bb_polls_total,
            null
        ) as bb_pct_online,
        coalesce(broadband_daily.bb_interrupts, 0) as bb_interrupts,
        coalesce(cm_uptime_daily.cm_uptime_hours, 0) as cm_uptime_hours,
        coalesce(cm_uptime_daily.cm_reboots, 0) as cm_reboots,
        coalesce(fixed_traffic_daily.fixed_kb_down, 0) as fixed_kb_down,
        coalesce(fixed_traffic_daily.fixed_kb_up, 0) as fixed_kb_up,
        coalesce(fixed_traffic_daily.fixed_avg_kbps_down, 0) as fixed_avg_kbps_down,
        coalesce(fixed_traffic_daily.fixed_avg_kbps_up, 0) as fixed_avg_kbps_up,
        coalesce(mobile_daily.mobile_sessions, 0) as mobile_sessions,
        coalesce(mobile_daily.mobile_dl_mb, 0) as mobile_dl_mb,
        coalesce(mobile_daily.mobile_ul_mb, 0) as mobile_ul_mb,
        coalesce(plume_daily.plume_reboots, 0) as plume_reboots,
        coalesce(signal_daily.signal_avg_snr_down_db, cm_uptime_daily.cm_snr_avg_down) as signal_avg_snr_down_db,
        signal_daily.signal_avg_power_down_dbmv,
        coalesce(dna_daily.dna_changes, 0) as dna_changes,
        fleet.broadband_plan_name as bb_plan_nm,
        fleet.broadband_plan_name as ao_plan_nm
    from device_dates
    inner join fleet
        on device_dates.account_id = fleet.account_id
        and device_dates.cm_mac = fleet.cm_mac
    left join broadband_daily
        on device_dates.account_id = broadband_daily.account_id
        and device_dates.cm_mac = broadband_daily.cm_mac
        and device_dates.dt = broadband_daily.dt
    left join cm_uptime_daily
        on device_dates.account_id = cm_uptime_daily.account_id
        and device_dates.cm_mac = cm_uptime_daily.cm_mac
        and device_dates.dt = cm_uptime_daily.dt
    left join fixed_traffic_daily
        on device_dates.account_id = fixed_traffic_daily.account_id
        and device_dates.cm_mac = fixed_traffic_daily.cm_mac
        and device_dates.dt = fixed_traffic_daily.dt
    left join mobile_daily
        on device_dates.account_id = mobile_daily.account_id
        and device_dates.cm_mac = mobile_daily.cm_mac
        and device_dates.dt = mobile_daily.dt
    left join plume_daily
        on device_dates.account_id = plume_daily.account_id
        and device_dates.cm_mac = plume_daily.cm_mac
        and device_dates.dt = plume_daily.dt
    left join signal_daily
        on device_dates.account_id = signal_daily.account_id
        and device_dates.cm_mac = signal_daily.cm_mac
        and device_dates.dt = signal_daily.dt
    left join dna_daily
        on device_dates.account_id = dna_daily.account_id
        and device_dates.cm_mac = dna_daily.cm_mac
        and device_dates.dt = dna_daily.dt

)

select * from joined
