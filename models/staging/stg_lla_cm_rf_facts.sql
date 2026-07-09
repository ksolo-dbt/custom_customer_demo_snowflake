with source as (

    select * from {{ source('lla_raw', 'cm_rf_facts') }}

),

renamed as (

    select
        lower("mac_address") as cm_mac,
        cast("poll_time" as timestamp_ntz) as poll_time,
        cast("ds_snr_db" as float) as ds_snr_db,
        cast("ds_power_dbmv" as float) as ds_power_dbmv,
        cast("us_snr_db" as float) as us_snr_db,
        cast("us_power_dbmv" as float) as us_power_dbmv,
        cast("uptime_seconds" as number) as uptime_seconds,
        cast("t3_timeouts" as number) as t3_timeouts,
        cast("t4_timeouts" as number) as t4_timeouts,
        "cmts_name"::varchar as cmts_name,
        cast("dt" as date) as dt
    from source

)

select * from renamed
