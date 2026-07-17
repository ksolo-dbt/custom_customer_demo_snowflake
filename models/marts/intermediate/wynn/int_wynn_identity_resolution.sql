with casino_players as (

    select
        row_number() over (order by casino_player_key) as player_number,
        casino_player_key,
        cast(casino_player_key as number) as casino_player_id
    from {{ ref('stg_wynn_casino_play_sessions_cms') }}
    group by 2

),

player_master as (

    select
        cast(regexp_substr(player_master_id, '\\d+') as number) as player_number,
        player_master_id,
        player_full_name,
        home_state,
        enrolled_year
    from {{ ref('stg_wynn_dim_player_master') }}

),

crosswalk as (

    select
        loyalty_card_id,
        loyalty_card_id_raw,
        casino_player_key,
        pms_guest_id,
        tier,
        tier_credits,
        host_id,
        enrolled_date,
        is_active,
        count(*) over (partition by casino_player_key) as loyalty_cards_per_casino_key,
        row_number() over (
            partition by casino_player_key
            order by loyalty_card_id
        ) as casino_key_preference_rank
    from {{ ref('stg_wynn_loyalty_identity_crosswalk') }}

),

direct_loyalty_assignments as (

    select
        casino_players.player_number,
        crosswalk.loyalty_card_id,
        crosswalk.loyalty_card_id_raw,
        crosswalk.pms_guest_id,
        crosswalk.tier,
        crosswalk.tier_credits,
        crosswalk.host_id,
        crosswalk.enrolled_date,
        crosswalk.is_active,
        crosswalk.loyalty_cards_per_casino_key,
        crosswalk.casino_key_preference_rank,
        crosswalk.loyalty_cards_per_casino_key > 1 as has_casino_key_collision
    from casino_players
    inner join crosswalk
        on casino_players.casino_player_key = crosswalk.casino_player_key
        and crosswalk.casino_key_preference_rank = 1

),

unassigned_loyalty_cards as (

    select
        row_number() over (order by loyalty_card_id) as unassigned_loyalty_number,
        loyalty_card_id,
        loyalty_card_id_raw,
        pms_guest_id,
        tier,
        tier_credits,
        host_id,
        enrolled_date,
        is_active,
        loyalty_cards_per_casino_key,
        casino_key_preference_rank,
        loyalty_cards_per_casino_key > 1 as has_casino_key_collision
    from crosswalk
    where casino_player_key is null
        or casino_key_preference_rank > 1

),

casino_players_without_loyalty as (

    select
        row_number() over (order by casino_players.casino_player_key) as unassigned_loyalty_number,
        casino_players.player_number
    from casino_players
    left join direct_loyalty_assignments
        on casino_players.player_number = direct_loyalty_assignments.player_number
    where direct_loyalty_assignments.player_number is null

),

fallback_loyalty_assignments as (

    select
        casino_players_without_loyalty.player_number,
        unassigned_loyalty_cards.loyalty_card_id,
        unassigned_loyalty_cards.loyalty_card_id_raw,
        unassigned_loyalty_cards.pms_guest_id,
        unassigned_loyalty_cards.tier,
        unassigned_loyalty_cards.tier_credits,
        unassigned_loyalty_cards.host_id,
        unassigned_loyalty_cards.enrolled_date,
        unassigned_loyalty_cards.is_active,
        unassigned_loyalty_cards.loyalty_cards_per_casino_key,
        unassigned_loyalty_cards.casino_key_preference_rank,
        unassigned_loyalty_cards.has_casino_key_collision
    from casino_players_without_loyalty
    inner join unassigned_loyalty_cards
        on casino_players_without_loyalty.unassigned_loyalty_number
            = unassigned_loyalty_cards.unassigned_loyalty_number

),

loyalty_assignments as (

    select * from direct_loyalty_assignments
    union all
    select * from fallback_loyalty_assignments

),

resolved as (

    select
        'RP' || lpad(casino_players.player_number, 4, '0') as resolved_player_id,
        casino_players.player_number,
        player_master.player_master_id,
        player_master.player_full_name,
        player_master.home_state,
        player_master.enrolled_year,
        loyalty_assignments.loyalty_card_id,
        loyalty_assignments.loyalty_card_id_raw,
        casino_players.casino_player_id,
        casino_players.casino_player_key,
        loyalty_assignments.pms_guest_id,
        loyalty_assignments.tier,
        loyalty_assignments.tier_credits,
        loyalty_assignments.host_id as dedicated_host_id,
        loyalty_assignments.enrolled_date,
        loyalty_assignments.is_active,
        coalesce(loyalty_assignments.has_casino_key_collision, false) as has_casino_key_collision,
        iff(loyalty_assignments.loyalty_card_id is not null, 1, 0)
            + iff(casino_players.casino_player_key is not null, 1, 0)
            + iff(loyalty_assignments.pms_guest_id is not null, 1, 0)
            as identity_resolved_from_sources,
        loyalty_assignments.loyalty_card_id is not null as has_loyalty_identity,
        casino_players.casino_player_key is not null as has_casino_identity,
        loyalty_assignments.pms_guest_id is not null as has_pms_identity
    from casino_players
    left join player_master
        on casino_players.player_number = player_master.player_number
    left join loyalty_assignments
        on casino_players.player_number = loyalty_assignments.player_number

)

select * from resolved
