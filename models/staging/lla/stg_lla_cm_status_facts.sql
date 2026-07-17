with source as (

    select * from {{ source('lla_raw', 'cm_status_facts') }}

),

renamed as (

    select
        lower("mac_address") as cm_mac,
        cast("poll_time" as timestamp_ntz) as poll_time,
        lower("cm_status") as cm_status,
        "ip_address"::varchar as ip_address,
        "cmts_name"::varchar as cmts_name,
        "upstream_port"::varchar as upstream_port,
        "downstream_port"::varchar as downstream_port,
        cast("dt" as date) as dt
    from source

)

select * from renamed
