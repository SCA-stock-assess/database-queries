# database-queries
Repository for querying and/or tidying data from DFO databases. Folders are organized by database/data source, rather than by data type, as a single function will often extract multiple types of data from a given database (e.g., age and escapement data from NuSEDS). 
All links below require connection to DFO network, and authentication with DFO network ID and password. Code will not work without DFO network access/account.

<br>

## Age and CWT data (MRPIS)
For age and CWT data stored by MRPIS (https://pac-salmon.dfo-mpo.gc.ca/CwtDataEntry/#/AgeBatchList), see/download the saaWeb package created by Nick Komick: https://github.com/Pacific-salmon-assess/saaWeb

- For age data: note that some historical age data are not yet in the "new PADS" (MRPIS) and are still in NuSEDS (for many areas, this is ~pre-2021, although they are working through adding historical data). See section below "NuSEDS" for how to access age data prior to 2021.
- The saaWeb package should also work for anything accessed through the MRP extractor: https://pac-salmon.dfo-mpo.gc.ca/DataExtractor/ 

<br>

## NuSEDS
For escapement data (and some historical age data) housed in NuSEDS and accessed by the NuSEDS query tool, use the following script in this repository:
- NuSEDS/extract_nuseds_data.R: https://github.com/SCA-stock-assess/database-queries/blob/main/NuSEDS/extract_nuseds_data.R 

<br>

## FOS
To connect to FOS, see the package FOSer by M. Folkes: https://gitlab.com/MichaelFolkes/foser. May require a FOS account. 

## Documentation to add in future: 
- Connection to CREST (?)
- Connection to EPRO (?)
- Connection to new Oto Manager (?)
- Connection(s) to new Salmon Space tools (?)

**If you would like to contribute, please add a folder with an informative name of either the name of the database being queried, or the type of data being queried. 
<br>

Maintainer:
Katie Davidson
