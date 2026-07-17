{{ config(materialized='table') }}

with identities as (

    select * from {{ ref('int_wynn_identity_resolution') }}

),

hosts as (

    select * from {{ ref('stg_wynn_dim_host') }}

),

tiers as (

    select * from {{ ref('stg_wynn_dim_tier') }}

),

trips as (

    select * from {{ ref('fct_wynn_player_trips') }}

),

casino_sessions as (

    select * from {{ ref('int_wynn_casino_sessions_enriched') }}

),

player_rollup as (

    select
        identities.resolved_player_id,
        identities.player_number,
        identities.player_master_id,
        identities.player_full_name,
        identities.home_state,
        identities.loyalty_card_id,
        identities.casino_player_id,
        identities.casino_player_key,
        identities.pms_guest_id,
        identities.tier,
        identities.tier_credits,
        identities.dedicated_host_id,
        hosts.host_name,
        hosts.host_book_tier,
        identities.enrolled_date,
        identities.is_active,
        identities.has_casino_key_collision,
        identities.identity_resolved_from_sources,
        identities.has_loyalty_identity,
        identities.has_casino_identity,
        identities.has_pms_identity,
        coalesce(sum(trips.gaming_theo_win), 0) as gaming_theo_win,
        coalesce(sum(trips.gaming_actual_win), 0) as gaming_actual_win,
        coalesce(sum(trips.hotel_ancillary_rev), 0) as hotel_ancillary_rev,
        coalesce(sum(trips.comp_dollars_issued), 0) as comp_dollars_issued,
        coalesce(sum(trips.blended_worth), 0) as blended_worth,
        coalesce(sum(trips.carded_sessions), 0) as carded_sessions,
        coalesce(sum(trips.hotel_stays), 0) as hotel_stays,
        coalesce(sum(trips.quality_flagged_sessions), 0) as quality_flagged_sessions,
        coalesce(sum(trips.no_folio_references), 0) as no_folio_references,
        coalesce(sum(trips.baccarat_hi_recode_sessions), 0) as baccarat_hi_recode_sessions,
        max(trips.trip_start_date) as last_trip_date,
        max(case when trips.carded_sessions > 0 then trips.trip_start_date end) as last_play_date,
        count(distinct trips.player_trip_id) as trips
    from identities
    left join trips
        on identities.resolved_player_id = trips.resolved_player_id
    left join hosts
        on identities.dedicated_host_id = hosts.host_id
    left join tiers
        on identities.tier = tiers.tier
    group by
        identities.resolved_player_id,
        identities.player_number,
        identities.player_master_id,
        identities.player_full_name,
        identities.home_state,
        identities.loyalty_card_id,
        identities.casino_player_id,
        identities.casino_player_key,
        identities.pms_guest_id,
        identities.tier,
        identities.tier_credits,
        identities.dedicated_host_id,
        hosts.host_name,
        hosts.host_book_tier,
        identities.enrolled_date,
        identities.is_active,
        identities.has_casino_key_collision,
        identities.identity_resolved_from_sources,
        identities.has_loyalty_identity,
        identities.has_casino_identity,
        identities.has_pms_identity

),

casino_recode_rollup as (

    select
        resolved_player_id,
        sum(iff(is_baccarat_hi_recode, coalesce(gaming_theo_win, 0), 0)) as baccarat_hi_recode_theo_win
    from casino_sessions
    group by 1

),

final as (

    select
        player_rollup.resolved_player_id,
        player_rollup.player_master_id,
        player_rollup.player_full_name,
        player_rollup.home_state,
        player_rollup.loyalty_card_id,
        player_rollup.casino_player_id,
        player_rollup.pms_guest_id,
        player_rollup.tier,
        player_rollup.tier_credits,
        player_rollup.dedicated_host_id,
        player_rollup.host_name,
        player_rollup.host_book_tier,
        player_rollup.dedicated_host_id is not null as is_hosted,
        player_rollup.enrolled_date,
        player_rollup.is_active,
        player_rollup.has_casino_key_collision,
        player_rollup.identity_resolved_from_sources,
        player_rollup.has_loyalty_identity,
        player_rollup.has_casino_identity,
        player_rollup.has_pms_identity,
        player_rollup.gaming_theo_win,
        player_rollup.gaming_actual_win,
        player_rollup.hotel_ancillary_rev,
        player_rollup.comp_dollars_issued,
        player_rollup.blended_worth,
        round(
            div0(player_rollup.comp_dollars_issued, nullif(player_rollup.blended_worth, 0)),
            4
        ) as comp_efficiency_ratio,
        round(player_rollup.gaming_theo_win - player_rollup.hotel_ancillary_rev, 2) as floor_vs_pms_worth_gap,
        player_rollup.carded_sessions,
        player_rollup.hotel_stays,
        player_rollup.trips,
        datediff(day, player_rollup.last_play_date, current_date) as days_since_last_play,
        player_rollup.last_trip_date,
        player_rollup.last_play_date,
        player_rollup.quality_flagged_sessions,
        player_rollup.no_folio_references,
        player_rollup.baccarat_hi_recode_sessions,
        coalesce(casino_recode_rollup.baccarat_hi_recode_theo_win, 0) as baccarat_hi_recode_theo_win,
        player_rollup.blended_worth >= 50000
            and player_rollup.dedicated_host_id is null
            as high_worth_unhosted_flag,
        player_rollup.blended_worth >= 50000
            and datediff(day, player_rollup.last_play_date, current_date) > 90
            as reactivation_flag
    from player_rollup
    left join casino_recode_rollup
        on player_rollup.resolved_player_id = casino_recode_rollup.resolved_player_id

)

select * from final
