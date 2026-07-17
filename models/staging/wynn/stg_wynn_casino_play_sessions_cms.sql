with source as (

    select * from {{ source('wynn_raw', 'wpv_casino_play_sessions_cms') }}

),

cleaned as (

    select
        trim(entity_id) as entity_id,
        cast(source_player_key as number) as casino_player_id,
        trim(cast(source_player_key as varchar)) as casino_player_key,
        nullif(trim(session_or_folio_id), '') as session_id,
        cast(fieldfid as number) as field_fid,
        nullif(trim(value), '') as value,
        nullif(trim(createdby), '') as created_by,
        cast(createdat as timestamp_ntz) as created_at
    from source

),

deduped as (

    select *
    from cleaned
    qualify row_number() over (
        partition by entity_id, casino_player_key, session_id, field_fid
        order by created_at desc, value desc
    ) = 1

),

pivoted as (

    select
        entity_id,
        casino_player_id,
        casino_player_key,
        session_id,
        try_to_decimal(regexp_replace(max(case when field_fid = 2001 then value end), '[^0-9.-]', ''), 18, 2) as gaming_theo_win,
        try_to_decimal(regexp_replace(max(case when field_fid = 2002 then value end), '[^0-9.-]', ''), 18, 2) as gaming_actual_win,
        try_to_decimal(regexp_replace(max(case when field_fid = 2003 then value end), '[^0-9.-]', ''), 18, 2) as avg_bet,
        try_to_decimal(regexp_replace(max(case when field_fid = 2004 then value end), '[^0-9.-]', ''), 18, 2) as time_on_device_min,
        max(case when field_fid = 2005 then value end) as game_type,
        try_to_date(max(case when field_fid = 2006 then value end)) as session_date,
        min(created_at) as first_created_at,
        max(created_at) as last_created_at
    from deduped
    group by 1, 2, 3, 4

)

select * from pivoted
