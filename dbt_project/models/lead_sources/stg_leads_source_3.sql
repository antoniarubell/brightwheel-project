with first_file_date as (
    select
        primary_key,
        file_name,
        file_date
    from {{ref('base_leads_source_3')}}
    qualify row_number() over (partition by primary_key order by file_date ASC) = 1
),

joined as (


    select
        --fields needed for dim_prospective_leads:
        'source_3' AS source_name,
        base.primary_key as source_id,
        base.phone_address_key,
        base.file_name,
        base.file_date,
        base.operation_name as company_name,
        base.address as street_address,
        base.city,
        base.state,
        base.zip as postal_code,
        base.phone,
        ff.file_date as first_received_file_date,
        ff.file_name as first_received_file_name,


        --other source-specific fields:
        base.type,
        base.issue_date,
        base.capacity,
        base.email_address,
        base.facility_id

from {{ref('base_leads_source_3')}} base 
left join first_file_date ff 
    on ff.primary_key = base.primary_key
)

select *
from joined
--take the most recent record for each source_id
qualify row_number() over (partition by phone_address_key order by file_date desc) = 1