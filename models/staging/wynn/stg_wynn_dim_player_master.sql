with source as (

    select * from {{ source('wynn_raw', 'dim_player_master') }}

),

renamed as (

    select
        nullif(trim(player_master_id), '') as player_master_id,
        nullif(trim(first_name), '') as first_name,
        nullif(trim(last_name), '') as last_name,
        trim(concat_ws(' ', first_name, last_name)) as player_full_name,
        nullif(trim(home_state), '') as home_state,
        cast(enrolled_year as number) as enrolled_year
    from source

)

select * from renamed
