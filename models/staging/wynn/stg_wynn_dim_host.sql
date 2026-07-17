with source as (

    select * from {{ source('wynn_raw', 'dim_host') }}

),

renamed as (

    select
        nullif(trim(c1), '') as host_id,
        nullif(trim(c2), '') as host_name,
        nullif(trim(c3), '') as host_book_tier
    from source
    where lower(trim(c1)) != 'host_id'

)

select * from renamed
