with source as (

    select * from {{ source('wynn_raw', 'wpv_loyalty_identity_crosswalk') }}

),

renamed as (

    select
        regexp_replace(trim(loyalty_card_id), '[^0-9]', '') as loyalty_card_id,
        trim(loyalty_card_id) as loyalty_card_id_raw,
        cast(casino_player_id as number) as casino_player_id,
        nullif(trim(cast(casino_player_id as varchar)), '') as casino_player_key,
        nullif(trim(pms_guest_id), '') as pms_guest_id,
        nullif(trim(tier), '') as tier,
        cast(tier_credits as number) as tier_credits,
        nullif(trim(host_id), '') as host_id,
        cast(enrolled_date as date) as enrolled_date,
        case
            when lower(trim(active_flag)) in ('y', 'yes', 'active', '1', 'true') then true
            when lower(trim(active_flag)) in ('n', 'no', 'inactive', '0', 'false') then false
        end as is_active
    from source

)

select * from renamed
