# This code is for if you have multiple xlsx exports from Otolith Manager that you want to join into one master file for quick analysis/plotting on. This is useful because sometimes OtoManager maxes out the number of rows it can export at once, making multi-year-area-species analyses difficult.
# It requires some prior steps:
## 1. You have visited http://devios-intra.dfo-mpo.gc.ca/Otolith/Reports/recoveryspecimen.aspx and downloaded the file(s) you want
## 2. The downloaded files are in their own folder location, wherever you want it


# Read multiple individual OtoManager files in R as a large list ---------------------------
# Load files from local computer to combine. Local is OK but not great. Mine are in a folder called "Oto Mgr compile (WCVI esc)" in "C:/Users/DAVIDSONKA/Documents/ANALYSIS/data/". Change the path to be whatever you want. 
otomgr.xlsxs <- lapply(list.files("C:/Users/DAVIDSONKA/Documents/ANALYSIS/data/Oto Mgr compile (WCVI esc)", 
                                  pattern = ".xlsx", 
                                  full.names = T), 
                                  function(x) {
                                    read_excel(x, sheet="RecoverySpecimens", skip=1, guess_max=20000)
                                  }
                      )

# Change the filenames in the List so it's clear which data came from which Excel file ---------------------------
names(otomgr.xlsxs) <- list.files("C:/Users/DAVIDSONKA/Documents/ANALYSIS/data/Oto Mgr compile (WCVI esc)", pattern = ".xlsx", full.names = T)


# Convert the Large List into a useable R dataframe ---------------------------
# Also add common columns to join to other data exports.
wcviOtoMgr_2015.22 <- do.call("rbind", otomgr.xlsxs) %>%
  tibble::rownames_to_column(var="file_source") %>%
  mutate(FACILITY = case_when(FACILITY=="H-ROBERTSON CR" ~ "H-ROBERTSON CREEK H",
                              FACILITY=="H-CONUMA R " ~ "H-CONUMA RIVER H ",
                              TRUE~as.character(FACILITY)),
         `(R) OTOLITH BOX NUM` = `BOX CODE`,
         `(R) OTOLITH VIAL NUM` = `CELL NUMBER`,
         `(R) OTOLITH LAB BUM` = `LAB NUMBER`,
         `(R) OTOLITH LBV CONCAT` = case_when(!is.na(`LAB NUMBER`) & !is.na(`BOX CODE`) & !is.na(`CELL NUMBER`) ~ 
                                              paste0(`LAB NUMBER`,sep="-",`BOX CODE`,sep="-",`CELL NUMBER`))) %>%
  mutate_at("(R) OTOLITH VIAL NUM", as.character) %>%
  select(-c(`...5`)) %>%
  print()


# Export compiled file for future use ---------------------------
# Here I am exporting to our working SharePoint folder for the Chinook terminal run reconstruction. Change the path to be whatever you want. 
write_xlsx(wcviOtoMgr_2015.22, path=paste0("C:/Users", sep="/", Sys.info()[6], sep="/",
                                           "DFO-MPO/PAC-SCA Stock Assessment (STAD) - Terminal CN Run Recon/TEST/data_prep_files/Otolith/OtoMgr_AllSpecies_A20-27andOffshore_2015-2022 - R output.xlsx"))


# ~ ~ ~ ~ ~ ~ ~ ~ ~ 
# HOUSEKEEPING/CONSIDERATIONS:
# If you are confident that the data above are static, this master file created above now contains data from 2015-2022 that does not have to be queried again. 
# To join escapement data in future, only need to download the most recent year of Otolith recovery data and rbind() to the "OtoMgr_AllSpecies_A20-27andOffshore_2015-2022 - R output" master file. 
# Although note, the new columns created that start with (R) in rows ~28-32 may preclude rbind(). Consider full_join() instead.
# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
