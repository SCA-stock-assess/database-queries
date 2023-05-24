# Code to dump data from the new PADS database hosted by MRPIS
# http://pac-salmon.dfo-mpo.gc.ca/CwtDataEntry/#/AgeBatchList
# Code from N. Komick/M. O'Brien/N. Brown
# May 2023


# ========================= SET UP =========================

# Load packages ---------------------------
library(tidyverse)
library(httr)          # for authenticate()
library(askpass)       # for askpass()

# Set sample year of interest ---------------------------
analysis_year <- 2022

# Compile credentials into http authentication function to access online DFO databases ---------------------------
auth <- authenticate(user = Sys.info()["login"], 
                     password = askpass::askpass(),              # will prompt you to enter your DFO network password once for the session.
                     type = 'ntlm')




# ========================= DEFINE EXTRACTION FUNCTIONS =========================

# Multiple functions are needed to access different parts of the PADS database right now. They produce different dataframes that are eventually joined below. 


# Function for getting container metadata (gives 'CtnStartDate' field) ---------------------------
get_container_meta <- function(batch_id){
  url <- paste0('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/odata/GetBatchContainers')
  request_body <- paste0(r"({"batch_id":")", batch_id, r"("})")
  x <- httr::POST(url, auth, body=request_body, encode="json", httr::verbose(), httr::content_type_json())
  y <-
    jsonlite::fromJSON(httr::content(x, "text"))$value |>
    dplyr::as_tibble() |>
    dplyr::mutate(across(c(FieldContainerId, ContainerNotes, AnalystName), as.character),
                  across(c(CntStartDate,CntEndDate), lubridate::as_date))
  return(y)
}



# Function for getting batch metadata (gives 'Location' field) ---------------------------
get_batch_meta <- function(batch_id){
  url <- paste0('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/api/AgeBatchDetail/GetAgeBatchDetail/', batch_id)
  x <- httr::GET(url, auth)
  batch_df <-
    httr::content(x, "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
  url <- 
    paste0("http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/odata/Project?$filter=Id eq ", batch_id) |>
    URLencode()
  y <- 
    httr::GET(url, auth) %>%
    httr::content(., "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON() 
  y <- 
    select(y$value, Id, Location) %>%
    inner_join(batch_df, by="Id")
  
  return(y)
}


# Function for extracting batch age results ---------------------------
get_age_data <- function(batch_id){
  url <- paste0('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/api/AgeBatchDetail/ScaleAgeDetail/', 
                batch_id)
  x <- httr::GET(url, auth)
  y <- batch_df_sc <- jsonlite::fromJSON(httr::content(x, "text"))
  return(y)
}





# ========================= EXTRACT DATA =========================

# Extract all South Coast scale batch IDs for SampleYear of interest and store in a vector of IDs called "PADS_batch_ids_2022" ---------------------------
PADS_batch_ids_2022 <- httr::GET('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/api/Report/GetAgeBatchList',
                                 auth) %>%
   # Get list of available age result batches:
  httr::content(x = .,  'text') %>%
  jsonlite::fromJSON() %>%
    # Filter batch list to keep only South Coast samples from 2022:
  filter(Sector == "SC",
         SampleYear == analysis_year) %>%
  pull(Id)                                                       # Extract column of age batch Ids from resulting dataframe



# Extract batch metadata, container metadata, and age data for scales in PADS_batch_ids_2022; Join into 1 dataframe ---------------------------
#   intermediate tables names are ignored for now, but can be run to help with diagnosing code issues if needed

allPADS_2022 <- 
  full_join(
    # Batch metadata ---
      # PADS_batch_meta <- 
    PADS_batch_ids_2022 %>%
      purrr::map_dfr(get_batch_meta) %>%
      rename(BatchId = Id), 
    # Container metadata ---
      # PADS_container_meta <- 
    PADS_batch_ids_2022 %>%
      purrr::map_dfr(get_container_meta) %>%
      rename(ContainerId = Id), 
    by="BatchId") %>%
  full_join(.,
            # Age data ---
              # PADS_age_data <- 
            PADS_batch_ids_2022 %>%
              purrr::map_dfr(get_age_data) %>%
              rename(BatchId = Id),
            by=c("BatchId", "ProjectName", "Region", "Area", "Species", "RecoveryYear", "LifeHistory", "ContainerId")) %>%          # DO NOT join by all fields as there are entry inconsistencies, e.g., "ProjectPriority==H vs ==High")
  mutate(`(R) SCALE BOOK NUM` = ContainerId,
         `(R) SCALE CELL NUM` = FishNumber,
         `(R) SCALE BOOK-CELL CONCAT` = case_when(!is.na(ContainerId) & !is.na(FishNumber) ~ paste0(ContainerId,sep="-",FishNumber))) %>%
  select(-c(AgingStructure)) %>%                       # remove duplicate column 
  print()


# Quick QC to make sure PADS join worked ---------------------------
nrow(PADS_batch_ids_2022 %>%
       purrr::map_dfr(get_age_data) %>%
       rename(BatchId = Id))
nrow(allPADS_2022)
# There will likely be a difference in the number of data rows in the Join vs. the number that have been aged - this is likely because the lab hasn't completed all aging yet. 


# Do the math to confirm that the unaged samples account for the difference (roughly); should result in TRUE: 
# (total # samples in PADS join) - (# unaged samples in the PADS join) == (total # samples available) 
nrow(allPADS_2022) - allPADS_2022%>%filter(is.na(GrAge)&is.na(ScaleCondition))%>%summarize(n=n())%>%pull(n) == nrow(PADS_batch_ids_2022 %>%
                                                                                                                      purrr::map_dfr(get_age_data) %>%
                                                                                                                      rename(BatchId = Id))
                                                                                                                      
# NOTE: there are sometimes a handful of issues, e.g., coho in a sockeye test fishery that won't always match up properly 
