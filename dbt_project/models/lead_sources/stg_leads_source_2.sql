with first_file_date as (
    select
        primary_key,
        file_name,
        file_date
    from {{ref('base_leads_source_2')}}
    qualify row_number() over (partition by primary_key order by file_date ASC) = 1
),

joined as (


    select
        --fields needed for dim_prospective_leads:
        'source_2' AS source_name,
        base.primary_key as source_id,
        base.phone_address_key,
        base.file_name,
        base.file_date,
        base.company as company_name,
        base.address1 as street_address,
        base.city,
        base.state,
        base.zip as postal_code,
        base.phone,
        ff.file_date as first_received_file_date,
        ff.file_name as first_received_file_name,


        --other source-specific fields:
        base.type_license,
        base.star_level,
        base.accepts_subsidy = 'Accepts Subsidy' as accepts_subsidy,

from {{ref('base_leads_source_2')}} base 
left join first_file_date ff 
    on ff.primary_key = base.primary_key
)

select *
from joined
--take the most recent record for each source_id
qualify row_number() over (partition by phone_address_key order by file_date desc) = 1