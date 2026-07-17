with source as (

    select * from {{ source('lla_raw', 'plume_reboot_fact') }}

),

renamed as (

    select
        lower("node_mac") as cm_mac,
        cast("reboot_time" as timestamp_ntz) as reboot_time,
        "reboot_reason"::varchar as reboot_reason,
        "firmware_version"::varchar as firmware_version,
        "location_id"::varchar as location_id,
        cast("dt" as date) as dt
    from source

)

select * from renamed
