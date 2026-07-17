{{ config(materialized='table') }}

with casino_sessions as (

    select * from {{ ref('int_wynn_casino_sessions_enriched') }}

),

hotel_folios as (

    select * from {{ ref('int_wynn_hotel_folios_enriched') }}

),

casino_trip_rollup as (

    select
        resolved_player_id,
        session_date as trip_start_date,
        session_date as trip_end_date,
        min(property) as property,
        count(*) as carded_sessions,
        count(distinct session_id) as distinct_casino_sessions,
        sum(coalesce(gaming_theo_win, 0)) as gaming_theo_win,
        sum(coalesce(gaming_actual_win, 0)) as gaming_actual_win,
        sum(coalesce(avg_bet, 0)) as avg_bet_total,
        sum(coalesce(time_on_device_min, 0)) as time_on_device_min,
        count_if(is_quality_flagged_session) as quality_flagged_sessions,
        count_if(is_baccarat_hi_recode) as baccarat_hi_recode_sessions
    from casino_sessions
    where resolved_player_id is not null
    group by 1, 2, 3

),

hotel_trip_rollup as (

    select
        resolved_player_id,
        stay_arrival_date as trip_start_date,
        dateadd(day, coalesce(max(stay_nights), 0), stay_arrival_date) as trip_end_date,
        min(property) as property,
        count(*) as hotel_stays,
        count(distinct folio_reference) as distinct_folio_references,
        sum(coalesce(room_revenue, 0)) as room_revenue,
        sum(coalesce(fnb_revenue, 0)) as fnb_revenue,
        sum(coalesce(retail_revenue, 0)) as retail_revenue,
        sum(coalesce(spa_revenue, 0)) as spa_revenue,
        sum(coalesce(show_revenue, 0)) as show_revenue,
        sum(coalesce(hotel_ancillary_rev, 0)) as hotel_ancillary_rev,
        sum(coalesce(comp_dollars_issued, 0)) as comp_dollars_issued,
        count_if(is_no_folio_reference) as no_folio_references
    from hotel_folios
    where resolved_player_id is not null
        and stay_arrival_date is not null
    group by 1, 2

),

trip_dates as (

    select
        resolved_player_id,
        trip_start_date
    from casino_trip_rollup
    union
    select
        resolved_player_id,
        trip_start_date
    from hotel_trip_rollup

),

joined as (

    select
        trip_dates.resolved_player_id
            || '-' || to_char(trip_dates.trip_start_date, 'YYYYMMDD')
            as player_trip_id,
        trip_dates.resolved_player_id,
        trip_dates.trip_start_date,
        greatest(
            coalesce(casino_trip_rollup.trip_end_date, trip_dates.trip_start_date),
            coalesce(hotel_trip_rollup.trip_end_date, trip_dates.trip_start_date)
        ) as trip_end_date,
        coalesce(casino_trip_rollup.property, hotel_trip_rollup.property) as property,
        coalesce(casino_trip_rollup.carded_sessions, 0) as carded_sessions,
        coalesce(casino_trip_rollup.distinct_casino_sessions, 0) as distinct_casino_sessions,
        coalesce(casino_trip_rollup.gaming_theo_win, 0) as gaming_theo_win,
        coalesce(casino_trip_rollup.gaming_actual_win, 0) as gaming_actual_win,
        coalesce(casino_trip_rollup.avg_bet_total, 0) as avg_bet_total,
        coalesce(casino_trip_rollup.time_on_device_min, 0) as time_on_device_min,
        coalesce(casino_trip_rollup.quality_flagged_sessions, 0) as quality_flagged_sessions,
        coalesce(casino_trip_rollup.baccarat_hi_recode_sessions, 0) as baccarat_hi_recode_sessions,
        coalesce(hotel_trip_rollup.hotel_stays, 0) as hotel_stays,
        coalesce(hotel_trip_rollup.distinct_folio_references, 0) as distinct_folio_references,
        coalesce(hotel_trip_rollup.room_revenue, 0) as room_revenue,
        coalesce(hotel_trip_rollup.fnb_revenue, 0) as fnb_revenue,
        coalesce(hotel_trip_rollup.retail_revenue, 0) as retail_revenue,
        coalesce(hotel_trip_rollup.spa_revenue, 0) as spa_revenue,
        coalesce(hotel_trip_rollup.show_revenue, 0) as show_revenue,
        coalesce(hotel_trip_rollup.hotel_ancillary_rev, 0) as hotel_ancillary_rev,
        coalesce(hotel_trip_rollup.comp_dollars_issued, 0) as comp_dollars_issued,
        coalesce(hotel_trip_rollup.no_folio_references, 0) as no_folio_references,
        round(
            coalesce(casino_trip_rollup.gaming_theo_win, 0) * 0.50
            + coalesce(hotel_trip_rollup.hotel_ancillary_rev, 0) * 0.35,
            2
        ) as blended_worth
    from trip_dates
    left join casino_trip_rollup
        on trip_dates.resolved_player_id = casino_trip_rollup.resolved_player_id
        and trip_dates.trip_start_date = casino_trip_rollup.trip_start_date
    left join hotel_trip_rollup
        on trip_dates.resolved_player_id = hotel_trip_rollup.resolved_player_id
        and trip_dates.trip_start_date = hotel_trip_rollup.trip_start_date

)

select * from joined
