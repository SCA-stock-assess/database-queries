
pkgs <- c("tidyverse", "httr", "jsonlite", "rstudioapi", "openxlsx", "here", "askpass")
#install.packages(pkgs)

library(tidyverse) # pipelines and data manipulation
library(rstudioapi) # To get source file details
library(httr) # For linking web data into R
library(jsonlite) # Convert web data into text
library(openxlsx) # Write into .xlsx format
library(here) # Ensure the data dump goes to the same folder as this R script
library(askpass) # Dialogue box for password

# Set wd to source file location
setwd(dirname(getActiveDocumentContext()$path))

# Set year of interest
curr_year <- 2023

# Thanks to Mike O'Brien and Nick Komick for the code below

# Get DFO username from system data
getSysUserName <- function() {
  whoami_result <- system2("whoami", stdout=TRUE)
  
  username <- strsplit(whoami_result, "\\", fixed=TRUE)[[1]][2]
  if(is.na(username)) {username <- whoami_result}
  
  return(username)
  
}

# Compile credentials into http authentication function
auth <- authenticate(user = getSysUserName(), 
                     password = askpass::askpass(), # Enter your DFO network password.
                     type = 'ntlm')


# Declare function for extracting data from a single batch
get_age_detail <- function(batch_id){
  url <- paste0('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/api/AgeBatchDetail/ScaleAgeDetail/', 
                batch_id)
  x <- httr::GET(url, auth)
  y <- batch_df_sc <- jsonlite::fromJSON(httr::content(x, "text"))
  return(y)
}

# Declare function for extracting aging batch details
get_batch_containers <- function(batch_id){
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

# Extract web data 
batch_list <- httr::GET('http://pac-salmon.dfo-mpo.gc.ca/Api.CwtDataEntry.v2/api/Report/GetAgeBatchList',
                        auth) %>%
  # Get list of available age result batches
  httr::content(x = .,  'text') |> 
  jsonlite::fromJSON() |>
  # Filter batch list to keep only South Coast samples from 2022
  filter(Sector == "SC",
         SampleYear == curr_year) |> 
  pull(Id) # Extract column of age batch Ids from resulting dataframe

  
# Extract age details
age_detail <- batch_list |>  
  purrr::map_dfr(get_age_detail) |> # Run each batch ID through the extractor function to extract its aging data
  mutate(across(c(ContainerId, FishNumber), as.numeric)) 

# Extract batch details
batch_detail <- batch_list |> 
   purrr::map_dfr(get_batch_containers) # Run each batch ID through the extractor function to extract its data


# Add batch details to individual readings
full <- age_detail |> 
  select(-AnalystName) |> # Will get from batch detail
  mutate(across(ContainerId, as.character)) |> 
  left_join(batch_detail, 
            # Not sure why, but the equivalency structure below seems to be correct
            by = join_by(Id == BatchId,
                         ContainerId == Id))

    
# Save the result
wb <- createWorkbook() # Open a new workbook
addWorksheet(wb, "Data") # Add a worksheet called "Data"

# Add age data to a new Excel table
writeDataTable(wb, 
               sheet = "Data", 
               x = full |> 
                 # Add a concatenated scalebook and fish number column to beginning of table for lookup
                 mutate(CONCAT = paste0(ContainerId, "_", FishNumber)) |> 
                 relocate(CONCAT), 
               tableName = "Data")

# Save the workbook
saveWorkbook(wb,
             file = paste0("All ", curr_year, " SC scale age results", ".xlsx"), # Export to xlsx
             overwrite = TRUE)

