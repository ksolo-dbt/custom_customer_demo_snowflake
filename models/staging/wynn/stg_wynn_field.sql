with source as (

    select * from {{ source('wynn_raw', 'wpv_field') }}

),

renamed as (

    select
        cast(field_uid as number) as field_uid,
        nullif(trim(fieldname), '') as field_name
    from source

)

select * from renamed
