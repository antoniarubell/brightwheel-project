/* 
Primary goal of base layer: monitor for schema-breaking changes in monthly refresh files, 
rather than allow those to persist to staging layer where some transformations are beginning to happen

Grain of table: Each lead contained in each monthly file (Source table is an append of all monthly files recieved). 
Deduping of leads across files happens downstream. 

*/

select
/* in the ingest process, we can capture a filename / date for downstream analytics 
on each file's quality */ 
    file_name,
    file_date,
    type_license,
    company,
    accepts_subsidy,
    year_round,
    daytime_hours,
    star_level,
    mon,
    tue,
    wed,
    thurs,
    friday,
    saturday,
    sunday,
    primary_caregiver,
    phone as phone_raw,
    REGEXP_REPLACE(phone, '[()\\s-]', '') AS phone,
    email,
    address1,
    address2,
    city,
    state,
    zip,
    subsidy_contract_number,
    total_cap,
    ages_accepted,
    aa2,
    aa3,
    aa4,
    license_monitoring_since,
    school_year_only,
    evening_hours,

    {{ dbt_utils.generate_surrogate_key(['file_name', 
                                        'phone',
                                        'address1']) }} AS primary_key,
    {{ dbt_utils.generate_surrogate_key(['phone',
                                        'address1']) }} AS phone_address_key
from {{source('sources','source_2')}}