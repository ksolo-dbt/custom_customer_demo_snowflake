with dna as (

    select * from {{ ref('stg_lla_dna_conv_service') }}

),

device_map as (

    select
        account_id,
        cm_mac,
        imei,
        msisdn
    from {{ ref('stg_lla_device_map') }}

),

filtered as (

    select
        dna.account_id,
        device_map.cm_mac,
        dna.msisdn,
        dna.imsi,
        dna.imei,
        dna.manufacturer,
        dna.device_model,
        dna.broadband_plan_name,
        dna.service_type,
        dna.service_status,
        dna.country,
        dna.dt
    from dna
    inner join device_map
        on dna.account_id = device_map.account_id
        and dna.imei = device_map.imei
        and dna.msisdn = device_map.msisdn
    where dna.device_model = 'IK41UD1'

)

select * from filtered
