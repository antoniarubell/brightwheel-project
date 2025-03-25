with all_prospective_leads as (
    select * from {{ref('stg_prospective_leads_source_1')}}

    union all 

    select * from {{ref('stg_prospective_leads_source_2')}}

    union all

    select * from {{ref('stg_prospective_leads_source_3')}}
)

select 
    --SOURCE IDENTIFIERS / METADATA
    l.source_name,
    l.source_id,
    l.contact_name,
    l.contact_title,
    l.company_name,
    --TODO: cleaning/normalization of addresses
    l.street_address,
    l.city,
    l.state,
    l.postal_code,
    l.country,
    l.phone,
    
    -- SALESFORCE FIELDS
    sf.id as salesforce_id,
    sf.is_deleted as is_deleted_in_salesforce,
    sf.created_date as created_in_salesforce_date,
    sf.last_modified_date as last_modified_in_salesforce_date,
    sf.is_converted,
    sf.outreach_stage,

    --LEAD LOGIC:
    salesforce_id is not null as is_lead_in_salesforce,
    NOT is_lead_in_salesforce as is_new_prospective_lead


    --LOGIC:
    --is_in_salesforce

    --and not is_deleted_in_salesforce

    from all_prospective_leads l 
    left join {{ref('stg_salesforce_leads')}} sf 
        on (l.phone = sf.phone OR l.phone = sf.mobile_phone)