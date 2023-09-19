# database-queries
Repo for querying and/or tidying data from DFO databases.

R scripts and .json query docs (as needed) used to access internal DFO databases. All links below require connection to DFO network, and authentication with DFO network ID and password. Databases with direct R queries to date are:
- PADS (NuSEDS), all salmon ages up to ~2021: http://pac-salmon.dfo-mpo.gc.ca/Nuseds.Query/#/Query](http://pac-salmon.dfo-mpo.gc.ca/Nuseds.Query/#/Query#r)
- PADS (MRPIS), all salmon and non-salmon ages from ~2021-onward (note historical data are slowly being added): http://pac-salmon.dfo-mpo.gc.ca/CwtDataEntry/#/AgeBatchList
- NuSEDS, all salmon escapement data: http://pac-salmon.dfo-mpo.gc.ca/Nuseds.Query/#/Query
- MRP CWT Extractor (MRPIS), all salmon Coded Wire Tag releases and recoveries: http://pac-salmon.dfo-mpo.gc.ca/DataExtractor/

DFO databases without direct R queries (yet...) but have tidying code:
- Otolith Manager: http://devios-intra.dfo-mpo.gc.ca/Otolith/Default.aspx

DFO databases without direct R queries and no tidying code yet:
- EPRO (SEP), major ops salmon hatchery information from 2022 onward: https://epro-stage.azure.cloud.dfo-mpo.gc.ca/EProWeb/#home
