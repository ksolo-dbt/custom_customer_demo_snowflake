with source as (

    select * from {{ source('wynn_raw', 'wpv_resolved_player_worth') }}

),

renamed as (

    select
        nullif(trim(resolved_player_id), '') as resolved_player_id,
        nullif(trim(player_full_name), '') as player_full_name,
        nullif(trim(to_varchar(loyalty_card_id)), '') as loyalty_card_id,
        cast(casino_player_id as number) as casino_player_id,
        nullif(trim(pms_guest_id), '') as pms_guest_id,
        nullif(trim(tier), '') as tier,
        cast(tier_credits as number) as tier_credits,
        nullif(trim(dedicated_host_id), '') as dedicated_host_id,
        cast(is_hosted as boolean) as is_hosted,
        cast(gaming_theo_win as decimal(18, 2)) as gaming_theo_win,
        cast(gaming_actual_win as decimal(18, 2)) as gaming_actual_win,
        cast(hotel_ancillary_rev as decimal(18, 2)) as hotel_ancillary_rev,
        cast(comp_dollars_issued as decimal(18, 2)) as comp_dollars_issued,
        cast(blended_worth as decimal(18, 2)) as blended_worth,
        cast(comp_efficiency_ratio as decimal(18, 4)) as comp_efficiency_ratio,
        cast(floor_vs_pms_worth_gap as decimal(18, 2)) as floor_vs_pms_worth_gap,
        cast(carded_sessions as number) as carded_sessions,
        cast(hotel_stays as number) as hotel_stays,
        cast(days_since_last_play as number) as days_since_last_play,
        cast(reactivation_flag as boolean) as reactivation_flag,
        cast(high_worth_unhosted_flag as boolean) as high_worth_unhosted_flag,
        cast(identity_resolved_from_sources as number) as identity_resolved_from_sources
    from source

)

select * from renamed
