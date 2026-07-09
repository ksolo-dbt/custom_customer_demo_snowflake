with broadband as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        bb_is_online,
        bb_interrupt_segment,
        bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        null::float as cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_broadband') }}

),

cm_uptime as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        cm_uptime_hours,
        cm_is_reboot,
        cm_t3_avg,
        cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_cm_uptime') }}

),

fixed_traffic as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        null::float as cm_snr_avg_down,
        fixed_kbps_down,
        fixed_kbps_up,
        fixed_kb_down,
        fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_fixed_traffic') }}

),

mobile_cdr as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        null::float as cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        mobile_dl_bytes,
        mobile_ul_bytes,
        mobile_traffic_mbps,
        mobile_apn,
        mobile_duration_min,
        mobile_network_type,
        mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_mobile_cdr') }}

),

reboots as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        null::float as cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        reboot_type,
        reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_reboots') }}

),

signal_quality as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        signal_rsrq_db,
        signal_rsrp_dbm,
        null::varchar as dna_change_type,
        null::varchar as dna_old_value,
        null::varchar as dna_new_value
    from {{ ref('int_lla_lane_signal_quality') }}

),

dna_changes as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        event_time,
        lane,
        null::number as bb_is_online,
        null::number as bb_interrupt_segment,
        null::float as bb_est_duration_15min,
        null::float as cm_uptime_hours,
        null::number as cm_is_reboot,
        null::number as cm_t3_avg,
        null::float as cm_snr_avg_down,
        null::number as fixed_kbps_down,
        null::number as fixed_kbps_up,
        null::number as fixed_kb_down,
        null::number as fixed_kb_up,
        null::number as mobile_dl_bytes,
        null::number as mobile_ul_bytes,
        null::float as mobile_traffic_mbps,
        null::varchar as mobile_apn,
        null::float as mobile_duration_min,
        null::varchar as mobile_network_type,
        null::varchar as mobile_cell_cdr,
        null::varchar as reboot_type,
        null::varchar as reboot_source,
        null::varchar as signal_rsrq_db,
        null::varchar as signal_rsrp_dbm,
        dna_change_type,
        dna_old_value,
        dna_new_value
    from {{ ref('int_lla_lane_dna_changes') }}

)

select * from broadband
union all
select * from cm_uptime
union all
select * from fixed_traffic
union all
select * from mobile_cdr
union all
select * from reboots
union all
select * from signal_quality
union all
select * from dna_changes
