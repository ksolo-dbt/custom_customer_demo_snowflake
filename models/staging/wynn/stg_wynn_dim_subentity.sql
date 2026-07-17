with source as (

    select * from {{ source('wynn_raw', 'dim_subentity') }}

),

renamed as (

    select
        nullif(trim(c1), '') as entity_id,
        nullif(trim(c2), '') as property,
        nullif(trim(c3), '') as business_line,
        nullif(trim(c4), '') as source_system,
        nullif(trim(c5), '') as customer_grain_definition,
        try_to_number(c6) as latency_sla_hrs,
        nullif(trim(c7), '') as key_format_note
    from source
    where lower(trim(c1)) != 'entity_id'

)

select * from renamed
