/* Grain of this table: one row per prospective lead per source. Ie. if multiple sources contain the same 
lead info, there will be multiple rows for that lead in this table. */

with all_prospective_leads as (
    select * from {{ref('stg_leads_source_1')}}
    union all 
    select * from {{ref('stg_leads_source_2')}}
    union all
    select * from {{ref('stg_leads_source_3')}}
)

select 
    --SOURCE IDENTIFIERS / METADATA
    {{ dbt_utils.generate_surrogate_key(['l.primary_key','source_name']) }} AS source_lead_key,
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
    l.first_received_file_date,
    l.first_received_file_name,
    row_number() over (partition by l.phone_address_key 
        order by l.first_received_file_date ASC) as is_first_received_lead,
    
    -- SALESFORCE FIELDS
    sf.id as salesforce_id,
    sf.is_deleted as is_deleted_in_salesforce,
    sf.created_date as created_in_salesforce_date,
    sf.last_modified_date as last_modified_in_salesforce_date,
    sf.is_converted,
    sf.outreach_stage,

    /* If a lead is not yet in Salesforce, it is a new prospective lead, and should be sent to sales to add to salesforce. */ 
    salesforce_id is null as is_new_prospective_lead

    from all_prospective_leads l 
    left join {{ref('stg_salesforce_leads')}} sf 
        on (l.phone = sf.phone OR l.phone = sf.mobile_phone)