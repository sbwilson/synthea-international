# Australia
Configuration files for Australian data. 

Produced by Dr Simon Wilson <simon@xeosdd.net>. Feedback and changes are welcome! 

## Data sources
The majority of data has come from the 2021 Census data from the Australian Bureau of Statistics. 
https://www.abs.gov.au/census/find-census-data/datapacks?release=2021&product=GCP&geography=ALL&header=S

Tables G1, G4, G8, G15, G17{A,B,C} and G49B were the primary data sources, along with the 2021_ASGS_MAIN_Structures table from 2021Census_geog_desc_1st_2nd_3rd_release.xls
This data was imported into a PostgreSQL 12 database for manipulation. I have included the schema and the query used to build demographcs.csv. 
The first-pass schema generation was performed using https://www.convertcsv.com/csv-to-sql.htm, with some minor adjustments. 

Hospital data from https://www.health.gov.au/resources/publications/list-of-declared-hospitals?language=en
Postcode data from https://www.matthewproctor.com/australian_postcodes 

This query took around 35s to generate the full result on an Apple Mac Studio M1 Max with 64GB RAM running Sonoma and PostgreSQL 16 via Postgres.app. It is far from optimised, but seems to produce the correct data. 

## Notes
For my puproses, I've used the [Australian Statistical Geography Standard (ASGS) Edition 3](https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026) classification of regions. The lowest level of data used for this work is the Statistical Area Level 2 (SA2) data -- "medium-sized general purpose areas ... [which] represent a community that interacts together socially and economically". For "county"-level data, I have chosen SA3, which provides "clustering groups of SA2s that have similar regional characteristics". SA2 gives 2,473 unique regions that cover Australia, that aim to cover an average of 10,000 people (range of 3k-25k). I had attempted to use the non-standard "suburbs and localities (SAL)" data to give more granularity, but in the end, using SA2 seems to be a good balance, giving a demographics.csv file that is approximately 2M in size. 

The assumption is that all persons here are eligible for Medicare. This is obviously not the case, but I have not yet had the need for this and hence have not looked further.

The Synthea demographics format is somewhat US-centric, and as such some accommodaitons have been made to account for this. In particular, since the ethnicity data included in the datapack only includes the "top 30" ethnicities in Australia, and with people being able to select one or two ethnicities, this data should be considered a rough estimate at best. None of the top 30 countries include any African countries, other than South Africa, but for the purposes of this data, they have been considered to be "white". Data for "asian" includes India and Sri Lanka, as well as South Pacific nations. 

Income data has been crudely bent to fit the categories -- see the SQL query to see how that is computed. 
