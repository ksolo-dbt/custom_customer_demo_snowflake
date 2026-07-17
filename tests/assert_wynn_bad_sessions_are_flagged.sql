select
    session_id,
    casino_player_key,
    session_date,
    gaming_theo_win,
    time_on_device_min
from {{ ref('int_wynn_casino_sessions_enriched') }}
where (
        gaming_theo_win < 0
        or time_on_device_min > 1440
    )
    and not is_quality_flagged_session
