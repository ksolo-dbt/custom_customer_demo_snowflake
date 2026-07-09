with device_map as (

    select
        column1::varchar as account_id,
        lower(column2::varchar) as cm_mac,
        column3::varchar as imei,
        column4::varchar as msisdn
    from values
        ('10000001', 'aa:bb:cc:dd:ee:01', '3570439200237514', '1913459363865'),
        ('10000002', 'aa:bb:cc:dd:ee:02', '3570439200237609', '1913459365305'),
        ('10000003', 'aa:bb:cc:dd:ee:03', '3570439200273214', '1913459365287')

)

select * from device_map
