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
    operation,
    operation_name,
    address,
    city,
    state,
    zip,
    county,
    phone as phone_raw,
    replace(phone, '-','') AS phone,
    type,
    status,
    issue_date,
    capacity,
    email_address,
    facility_id,
    infant = 'Y' as infant,
    toddler = 'Y' as toddler,
    preschool = 'Y' as preschool,
    school = 'Y' as school,

    {{ dbt_utils.generate_surrogate_key(['file_name', 
                                        'phone',
                                        'address']) }} AS primary_key,
    {{ dbt_utils.generate_surrogate_key(['phone',
                                        'address']) }} AS phone_address_key
from {{source('sources','source_3')}}