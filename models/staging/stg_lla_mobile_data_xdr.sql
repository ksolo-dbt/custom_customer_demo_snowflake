with source as (

    select * from {{ source('lla_raw', 'mobile_data_xdr') }}

),

renamed as (

    select
        to_varchar("served_imeisv") as imei,
        to_varchar("served_msisdn") as msisdn,
        try_to_timestamp_ntz(lpad(to_varchar("start_time"), 12, '0'), 'YYMMDDHH24MISS') as start_time,
        try_to_timestamp_ntz(lpad(to_varchar("end_time"), 12, '0'), 'YYMMDDHH24MISS') as end_time,
        cast("duration_seconds" as number) as duration_seconds,
        cast("volume_uplink_bytes" as number) as volume_uplink_bytes,
        cast("volume_downlink_bytes" as number) as volume_downlink_bytes,
        "rat_type"::varchar as rat_type,
        "cell_id"::varchar as cell_id,
        "apn"::varchar as apn,
        cast("dt" as date) as dt
    from source

)

select * from renamed
