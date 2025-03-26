/* Grain of this table: one row per prospective lead (unique by phone/address) */

select 
    phone_address_key,
    max(phone) as phone,
    max(address) as address,
    min(first_received_file_date) as first_received_file_date,
    max(case when is_first_received_lead = 1 then source_name end) as first_received_from_source,
    max(case when is_first_received_lead = 1 then first_received_file_name end) as first_received_from_file_name,
    min(created_in_salesforce_date) as created_in_salesforce_date,
    max(last_modified_in_salesforce_date) as last_modified_in_salesforce_date,
    max(is_converted) as is_converted,
    max(outreach_stage) as outreach_stage,
    max(is_new_prospective_lead) as is_new_prospective_lead,

    boolor_agg(source_name = 'source_1') as is_in_source_1,
    boolor_agg(source_name = 'source_2') as is_in_source_2,
    boolor_agg(source_name = 'source_3') as is_in_source_3,

    
from {{ref('dim_prospective_leads_source_level')}}
group by phone_address_key