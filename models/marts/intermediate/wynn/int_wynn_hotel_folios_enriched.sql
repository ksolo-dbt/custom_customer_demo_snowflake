with folios as (

    select * from {{ ref('stg_wynn_hotel_ancillary_folios_pms') }}

),

identities as (

    select * from {{ ref('int_wynn_identity_resolution') }}

),

subentities as (

    select * from {{ ref('stg_wynn_dim_subentity') }}

),

enriched as (

    select
        identities.resolved_player_id,
        identities.player_number,
        identities.player_full_name,
        folios.entity_id,
        subentities.property,
        subentities.source_system,
        folios.pms_guest_id,
        folios.folio_id,
        folios.folio_reference,
        folios.room_revenue,
        folios.fnb_revenue,
        folios.retail_revenue,
        folios.spa_revenue,
        folios.show_revenue,
        coalesce(folios.room_revenue, 0)
            + coalesce(folios.fnb_revenue, 0)
            + coalesce(folios.retail_revenue, 0)
            + coalesce(folios.spa_revenue, 0)
            + coalesce(folios.show_revenue, 0)
            as hotel_ancillary_rev,
        folios.stay_arrival_date,
        folios.stay_nights,
        folios.comp_dollars_issued,
        folios.folio_id is null as is_no_folio_reference,
        identities.resolved_player_id is null as is_unresolved_hotel_key,
        folios.first_created_at,
        folios.last_created_at
    from folios
    left join identities
        on folios.pms_guest_id = identities.pms_guest_id
        or folios.pms_guest_id = identities.loyalty_card_id
    left join subentities
        on folios.entity_id = subentities.entity_id

)

select * from enriched
