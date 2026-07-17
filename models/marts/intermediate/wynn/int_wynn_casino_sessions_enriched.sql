with sessions as (

    select * from {{ ref('stg_wynn_casino_play_sessions_cms') }}

),

identities as (

    select * from {{ ref('int_wynn_identity_resolution') }}

),

subentities as (

    select * from {{ ref('stg_wynn_dim_subentity') }}

),

game_types as (

    select * from {{ ref('stg_wynn_dim_game_type') }}

),

enriched as (

    select
        identities.resolved_player_id,
        identities.player_number,
        identities.player_full_name,
        sessions.entity_id,
        subentities.property,
        subentities.source_system,
        sessions.casino_player_id,
        sessions.casino_player_key,
        sessions.session_id,
        sessions.session_date,
        sessions.game_type as source_game_type,
        case
            when sessions.game_type = 'Baccarat-Hi'
                and sessions.session_date < '2026-01-01'
                then 'Baccarat'
            else sessions.game_type
        end as normalized_game_type,
        sessions.game_type = 'Baccarat-Hi'
            and sessions.session_date < '2026-01-01'
            as is_baccarat_hi_recode,
        sessions.gaming_theo_win,
        sessions.gaming_actual_win,
        sessions.avg_bet,
        sessions.time_on_device_min,
        game_types.theo_hold_pct,
        game_types.avg_decisions_per_hr,
        case
            when sessions.gaming_theo_win < 0 then true
            when sessions.time_on_device_min > 1440 then true
            when sessions.session_date between '2025-11-01' and '2025-11-30'
                and (
                    sessions.gaming_theo_win < 0
                    or sessions.time_on_device_min > 1440
                )
                then true
            else false
        end as is_quality_flagged_session,
        sessions.first_created_at,
        sessions.last_created_at
    from sessions
    left join identities
        on sessions.casino_player_key = identities.casino_player_key
    left join subentities
        on sessions.entity_id = subentities.entity_id
    left join game_types
        on (
            case
                when sessions.game_type = 'Baccarat-Hi'
                    and sessions.session_date < '2026-01-01'
                    then 'Baccarat'
                else sessions.game_type
            end
        ) = game_types.game_type

)

select * from enriched
