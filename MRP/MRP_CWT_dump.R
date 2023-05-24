# Code to dump data from CWT database hosted by MRP
# http://pac-salmon.dfo-mpo.gc.ca/DataExtractor/
# Code adapted from N. Komick 
# May 2023
# ***REQUIRES .json QUERY DOC: pads_nuseds_2020-2022.json - this may have to be updated for what you want specifically, but for now is just for 2022 relseases dump for all facilities. 
# Note: the query docs require the DataSource field to be changed whether you want CWT releases, recoveries, or releases join recoveries. Ask KD how to do this if you are not sure.


# ========================= SET UP =========================

# Load packages ---------------------------
library(tidyverse)
library(httr)          # for authenticate()
library(askpass)       # for askpass()

# Define query doc for extraction below (WILL NEED TO DEFINE LOCATION ON YOUR MACHINE AS YOU SEE FIT) ---------------------------
mrpJSONqry <- "mrp_releases2022.json"


# ========================= DEFINE EXTRACTION FUNCTIONS =========================

getExtractorData <- function(query_doc, password = NULL) {
  extractor_url <- "http://pac-salmon.dfo-mpo.gc.ca/Api.DataExtractor.v2/api/DynamicQuery/QueryResult"
  
  if(file.exists(query_doc)) {
    query_file <- file(query_doc, "r")
    query_doc <- readLines(query_file)
    close(query_file)
  }
  
  user_name <- Sys.getenv("username")
  if(is.null(password)) {
    password <- askpass(paste0("Please enter your password for ",
                               user_name,
                               ":"))
    
  }
  
  data_response <-
    POST(extractor_url,
         authenticate(user_name, password, "ntlm"),
         encode = "json",
         content_type_json(),
         body = query_doc)
  cwt_data <- content(data_response)
  
  
  cwt_col_names <- unlist(cwt_data$Names)
  extractor_data <-
    lapply(cwt_data$Rows,
           function(.) {
             as_tibble(.$Cells, .name_repair = ~ cwt_col_names)
           }) %>%
    bind_rows()
  
  
  col_types <- unlist(cwt_data$Types)
  
  int_col <- cwt_col_names[grepl("int", col_types, ignore.case = TRUE)]
  dbl_col <- cwt_col_names[grepl("single", col_types, ignore.case = TRUE)]
  
  extractor_data <-
    extractor_data %>%
    mutate(across(all_of(int_col), as.integer)) %>%
    mutate(across(all_of(dbl_col), as.double))
  
  return(extractor_data)
}




# ========================= EXTRACT DATA =========================

padsDump <- getExtractorData(query_doc=mrpJSONqry, password=NULL)   # will prompt to enter DFO network password


# Export from here as .csv or .xlsx as you wish
