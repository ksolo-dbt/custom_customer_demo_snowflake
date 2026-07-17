with source as (

    select * from {{ source('lla_raw', 'cm_data_day_facts') }}

),

renamed as (

    select
        lower("mac_address") as cm_mac,
        cast("date_key" as date) as date_key,
        cast("total_bytes_down_kb" as number) as total_bytes_down_kb,
        cast("total_bytes_up_kb" as number) as total_bytes_up_kb,
        cast("avg_speed_down_kbps" as number) as avg_speed_down_kbps,
        cast("avg_speed_up_kbps" as number) as avg_speed_up_kbps,
        cast("peak_speed_down_kbps" as number) as peak_speed_down_kbps,
        cast("peak_speed_up_kbps" as number) as peak_speed_up_kbps,
        cast("dt" as date) as dt
    from source

)

select * from renamed
