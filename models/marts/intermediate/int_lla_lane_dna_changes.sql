with fleet_base as (

    select * from {{ ref('int_lla_fleet_base') }}

),

with_previous as (

    select
        *,
        lag(broadband_plan_name) over (
            partition by account_id
            order by dt
        ) as previous_broadband_plan_name,
        lag(service_status) over (
            partition by account_id
            order by dt
        ) as previous_service_status
    from fleet_base

),

plan_changes as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        cast(dt as timestamp_ntz) as event_time,
        'dna_changes' as lane,
        'broadband_plan_name' as dna_change_type,
        previous_broadband_plan_name as dna_old_value,
        broadband_plan_name as dna_new_value
    from with_previous
    where previous_broadband_plan_name is not null
        and previous_broadband_plan_name != broadband_plan_name

),

status_changes as (

    select
        account_id,
        cm_mac,
        msisdn,
        imsi,
        imei,
        manufacturer,
        device_model,
        dt,
        cast(dt as timestamp_ntz) as event_time,
        'dna_changes' as lane,
        'service_status' as dna_change_type,
        previous_service_status as dna_old_value,
        service_status as dna_new_value
    from with_previous
    where previous_service_status is not null
        and previous_service_status != service_status

)

select * from plan_changes
union all
select * from status_changes
