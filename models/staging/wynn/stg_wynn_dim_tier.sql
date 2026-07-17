with source as (

    select * from {{ source('wynn_raw', 'dim_tier') }}

),

renamed as (

    select
        nullif(trim(tier), '') as tier,
        cast(tier_credits_min as number) as tier_credits_min,
        cast(dedicated_host as boolean) as dedicated_host,
        cast(comp_dollars_rate as decimal(18, 4)) as comp_dollars_rate,
        cast(freecredit_rate as decimal(18, 4)) as freecredit_rate
    from source

)

select * from renamed
