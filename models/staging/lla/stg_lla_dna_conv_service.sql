with source as (

    select * from {{ source('lla_raw', 'dna_conv_service') }}

),

renamed as (

    select
        to_varchar("account_id") as account_id,
        "customer_name"::varchar as customer_name,
        "srv_serv_type"::varchar as service_type,
        "pd_bb_prod_nm"::varchar as broadband_plan_name,
        to_varchar("imsi") as imsi,
        to_varchar("imei") as imei,
        to_varchar("msisdn") as msisdn,
        "nr_manufacturer_id"::varchar as manufacturer,
        "nr_device_model_name_sale"::varchar as device_model,
        "srv_status"::varchar as service_status,
        "country"::varchar as country,
        cast("dt" as date) as dt
    from source

)

select * from renamed
