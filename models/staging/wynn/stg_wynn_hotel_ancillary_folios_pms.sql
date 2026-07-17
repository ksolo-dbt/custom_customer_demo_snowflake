with source as (

    select * from {{ source('wynn_raw', 'wpv_hotel_ancillary_folios_pms') }}

),

cleaned as (

    select
        trim(entity_id) as entity_id,
        nullif(trim(source_player_key), '') as pms_guest_id,
        nullif(trim(session_or_folio_id), '') as folio_id,
        cast(fieldfid as number) as field_fid,
        nullif(trim(value), '') as value,
        nullif(trim(createdby), '') as created_by,
        cast(createdat as timestamp_ntz) as created_at
    from source

),

referenced as (

    select
        *,
        coalesce(
            folio_id,
            'NO_FOLIO_' || pms_guest_id || '_' || to_char(created_at, 'YYYYMMDDHH24MISS')
        ) as folio_reference
    from cleaned

),

deduped as (

    select *
    from referenced
    qualify row_number() over (
        partition by entity_id, pms_guest_id, folio_reference, field_fid
        order by created_at desc, value desc
    ) = 1

),

pivoted as (

    select
        entity_id,
        pms_guest_id,
        folio_id,
        folio_reference,
        try_to_decimal(regexp_replace(max(case when field_fid = 3001 then value end), '[^0-9.-]', ''), 18, 2) as room_revenue,
        try_to_decimal(regexp_replace(max(case when field_fid = 3002 then value end), '[^0-9.-]', ''), 18, 2) as fnb_revenue,
        try_to_decimal(regexp_replace(max(case when field_fid = 3003 then value end), '[^0-9.-]', ''), 18, 2) as retail_revenue,
        try_to_decimal(regexp_replace(max(case when field_fid = 3004 then value end), '[^0-9.-]', ''), 18, 2) as spa_revenue,
        try_to_decimal(regexp_replace(max(case when field_fid = 3005 then value end), '[^0-9.-]', ''), 18, 2) as show_revenue,
        try_to_date(max(case when field_fid = 3006 then value end)) as stay_arrival_date,
        try_to_decimal(regexp_replace(max(case when field_fid = 3007 then value end), '[^0-9.-]', ''), 18, 2) as stay_nights,
        try_to_decimal(regexp_replace(max(case when field_fid = 3008 then value end), '[^0-9.-]', ''), 18, 2) as comp_dollars_issued,
        min(created_at) as first_created_at,
        max(created_at) as last_created_at
    from deduped
    group by 1, 2, 3, 4

)

select * from pivoted
