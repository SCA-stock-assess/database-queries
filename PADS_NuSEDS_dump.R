# Code to dump data from the old PADS database hosted by NuSEDS
# http://pac-salmon.dfo-mpo.gc.ca/Nuseds.Query/#/Query#r
# Code adapted from N. Komick 
# May 2023
# ***REQUIRES .json QUERY DOC: pads_nuseds_2020-2022.json - this may have to be updated for what you want specifically, but for now is just for 2020-2022 ages dump. 


# ========================= SET UP =========================

# Load packages ---------------------------
library(tidyverse)
library(httr)          # for authenticate()
library(askpass)       # for askpass()

# Define query doc for extraction below (WILL NEED TO DEFINE LOCATION ON YOUR MACHINE AS YOU SEE FIT) ---------------------------
padsJSONqry <- "pads_nuseds_2020-2022.json"


# ========================= DEFINE EXTRACTION FUNCTIONS =========================

getOldPADS <- function(query_doc, password = NULL) {
  nuseds_url <- "http://pac-salmon.dfo-mpo.gc.ca/Api.NuSEDS.v2/api/DynamicQuery/QueryResult"
  
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
    POST(nuseds_url,
         authenticate(user_name, password, "ntlm"),
         encode = "json",
         content_type_json(),
         body = query_doc)
  nuseds_data <- content(data_response)
  
  nuseds_col_names <- unlist(nuseds_data$Names)
  nuseds_data <-
    lapply(nuseds_data$Rows,
           function(.) {
             as_tibble(.$Cells, .name_repair = ~ nuseds_col_names)
           }) %>%
    bind_rows()
  col_types <- unlist(nuseds_data$Types)
  int_col <- nuseds_col_names[grepl("int", col_types, ignore.case = TRUE)]
  dbl_col <- nuseds_col_names[grepl("single", col_types, ignore.case = TRUE)]
  nuseds_data <-
    nuseds_data %>%
    mutate(across(all_of(int_col), as.integer)) %>%
    mutate(across(all_of(dbl_col), as.double))
  
  return(nuseds_data)
}




# ========================= EXTRACT DATA =========================

padsDump <- getOldPADS(query_doc=padsJSONqry, password=NULL)   # will prompt to enter DFO network password


# Export from here as .csv or .xlsx as you wish

