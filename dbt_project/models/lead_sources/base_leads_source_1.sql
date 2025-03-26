/* 
Grain of table: Each lead contained in each monthly file (Source table is an append of all monthly files recieved). 
Deduping of leads across files happens downstream. 
*/

select
/* in the ingest process, we can capture a filename / date for downstream analytics 
on each file's quality */ 
    file_name,
    file_date,
    name,
    credential_type,
    credential_number,
    status,
    expiration_date::DATE AS first_issue_date,
    disciplinary_action,
    address,
    state,
    county,
    phone as phone_raw,
    REPLACE(base.phone, '-','') AS phone,
    first_issue_date::DATE AS first_issue_date,
    primary_contact_name,
    primary_contact_role,

    {{ dbt_utils.generate_surrogate_key(['file_name','phone','address']) }} AS primary_key,
    {{ dbt_utils.generate_surrogate_key(['phone','address']) }} AS phone_address_key
from {{source('sources','source_1')}}