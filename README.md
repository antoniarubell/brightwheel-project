# brightwheel-project

## Data Model Overview

base_leads_source_* tables: 
- The primary goal of this base layer is to catch schema-breaking changes in the source files, as they may change each month. If a column name changes, we will expect a failure here, and can address. 
- Grain is file-lead-level

stg_leads_source_* tables: 
- This layer preps and standardizes the columns needed across sources to merge them all together downstream.
- Only the latest occurrence of a lead in a file is kept here, so now the grain is lead-level.
- File-name/date of the first file a lead appeared in is captured here, to support analytics

dim_prospective_leads_source_level:
- All staging data is unioned together, so that each source's leads are in one place (if a lead exists across sources, there will be multiple rows here)

dim_prospective_leads:
- Finally, a lead-level grain table, showing only one row per address/phone key.
- This table can be used for analytics such as: how many net-new leads have been generated by each source, and each file? What is lead overlap between sources?

## Data Exploration
Types of things I explored primarly were mostly to understand the granularity of the data, and how we can handle lead resolution. Ex:
- Do we get multiple contacts per lead?
- Is phone number sufficient for lead resolution? Or do we need to rely on address as well?
- ...in which case, is address clean enough to rely on?
- Should leads be contact-level or company-level? (ex - if we have multiple contacts for same company?)
- What should we do in case of a duplicate? How do we decide which row to use?

## Assumptions
I made some assumptions in order to proceed:
- Monthly full-refresh file mechanism will store all records in an **append-only table** with `file_name` and `file_date` for tracking. Storing each file in full allows us to do file-level analytics (ie. what % of leads in file are net-new?). Also assumes we have enough storage for this approach
- **Phone-address pairs** should be treated as separate leads, so that if we have multiple addresses for one phone number, we will load those each to salesforce separately.

## Testing & Data Validation
- Created primary keys to represent the different grains of data, that can be tested for uniqueness throughout the pipeline
- Data validation on phone number, which is important as a unique identifier (ensuring a 10-digit number, no special characters)
- Other important fields should have testing/data validation as well

## Tradeoffs / Future considerations

**Lead Resolution**: 
- I'm unclear if phone number should be the sole primary identifier, and when we should rely on address. Here, I used both phone + address as the unique identifier, I can probably be more savvy about when to use address vs. when phone number is sufficient
- Phone numbers / addresses can change, and I ignored that aspect entirely in this prototype. I see a brightwheel_id custom field in the salesforce data, which will be the ultimate stable resolution ID. Ideally, the data team maintains a resolution table that maps all phones/addresses in our ecosystem to brightwheel_ids and salesforce_ids, and can act as a lookup for IDs. For now, I joined salesforce data directly onto the source data using phone/mobile phone numbers.

**Data Cleaning**:
- For now, I cleaned phone numbers manually in each source type. But we should have a column-level cleaning macro that can be used wherever we import phone numbers from sources. 
- I didn't do any cleaning of addresses at all here, but addresses should be cleaned in some way (a trickier problem). With addresses uncleaned as is, we can dedupe leads within a source, but unless addresses are normalized between sources, we cannot yet dedupe leads that may exist in multiple sources.

**New vs. Updated Leads**:
- I prioritized identifying new prospective leads to load into Salesforce. However we can also receive new information about an existing lead which may be helpful in the sales cycle. So we should build flags to identify when we there is new info for important fields, compared to what's in salesforce, which then could be passed to Sales team as well.

**Salesforce Profile Creation**:
- If we do identify a new lead to load into Salesforce, I'm assuming we'll need to provide Sales team all the info to create the company profile. I don't think the `dim_prospective_leads` table can/should be the place for all of that relevant company metadata, but we should help streamline the process of building out that salesforce profile

**Lead Analytics**:
- I focused on building out the new prospective leads identification process, and supporting file/source analytics, in order to support Sales operations as a first priority. Next up, would be supporting analytics on Salesforce leads - ie. how long does it take for leads to move through statuses? What % are in each status week over week? 
- We'll need historical lead status data to build trends / know which leads were in which status at different points in time. I'm not sure if Salesforce provides log/history tables? (Most ideal!) But we could consider DBT snapshotting

**Testing / Validation**:
- My tests thus far are very simple (uniqueness / non-null / data validation). But we could use DBT packages like great-expectations to actually test higher-level things, such as the # of rows in each file
- Sources have very different formats for company / contact names. I'm not sure how important a clean company name is to have in Salesforce (for ex. one source included the caregiver name in the company name), so I passed through whatever was provided. However additional cleaning / formatting may be needed

## Long-term ETL Strategy
As mentioned above, because Brighthweel is working with so many different sources, I imagine resolution of leads is an ongoing data challenge. I am thinking that as part of onboarding new sources / loading new monthly files, phone numbers / addresses should be copied into raw database tables and stored, linked to brightwheel_ids and salesforce_ids once those have been generated. Then if phone numbers/addresses change over time, we have all historical mappings. 

This data model identifies new leads to load into Salesforce, but I could see us orchestrating a job to actually take any `is_new_prospective_lead = TRUE` rows, and format a file with all fields needed to create a Salesforce profile, and automatically send it to the Sales team, via slack or something of the sort.

I'm unclear on how big of an issue schema-breaking changes are in monthly file refreshes, and how much manual work is requried to resolve. If it is a big problem, then limiting the base / staging tables to only pull the most essential columns may reduce some change management burden (rather than pulling every column available in).
