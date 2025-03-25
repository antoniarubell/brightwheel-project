select
    --fields needed for dim_prospective_leads:
    'source_1' AS source_name,
    credential_number as source_id,
    file_name,
    file_date,
    primary_contact_name as contact_name,
    primary_contact_role as contact_title,
    name as company_name,
    address as street_address,
    null as city,
    state,
    postal_code,
    REPLACE(phone, '-','') AS phone,

    --other source-specific fields:
    credential_type,
    credential_number,
    status,
    expiration_date,
    disciplinary_action,
    county,
    first_issue_date

from {{ref('base_leads_source_1')}}
--take the most recent record for each source_id
qualify row_number() over (partition by source_id order by file_date desc) = 1