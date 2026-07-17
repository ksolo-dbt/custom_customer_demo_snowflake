with source as (

    select * from {{ source('wynn_raw', 'dim_game_type') }}

),

renamed as (

    select
        nullif(trim(game_type), '') as game_type,
        cast(theo_hold_pct as decimal(18, 4)) as theo_hold_pct,
        cast(avg_decisions_per_hr as number) as avg_decisions_per_hr
    from source

)

select * from renamed
