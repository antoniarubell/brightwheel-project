select 
    --SOURCE IDENTIFIERS / METADATA
    source_name,
    source_id,
    contact_name,
    contact_title,
    company_name,
    street_address,
    city,
    state,
    postal_code,
    country,
    phone,
    


    -- SALESFORCE FIELDS
    salesforce_id,
    is_deleted_in_salesforce,
    created_in_salesforce_date,
    last_modified_in_salesforce_date,
    is_converted,
    outreach_stage,


    --LOGIC:
    --is_in_salesforce

    --and not is_deleted_in_salesforce