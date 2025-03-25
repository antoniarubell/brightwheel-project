/* primary goal of base layer here is to monitor for schema-breaking 
changes in monthly refresh files */

select
/* ideally in the ingest process, we can capture a filename / date for downstream analytics 
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
    phone,
    first_issue_date::DATE AS first_issue_date,
    primary_contact_name,
    primary_contact_role
from {{source('sources','source_1')}}