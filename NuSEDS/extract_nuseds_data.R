# Use script below to access any data stored in NuSEDS (escapement or ages)

# You will require a saaWeb.config file, which can be found here for South Coast StA members: SCD_Stad\saaWeb.config
# Download this and save it to wherever your working directory is. Do not post this to github/publicly as there can be security issues with providing APIs.  

# First step is to define the function to access the data
# Second step is to use the function to extract the data
  # The type of data you want to extract (escapement or ages) is specified in the .json query doc. The runNuSEDSQuery function will work for either. 
# Last is some suggested export code to export the result to an Excel file in the location of your choice, but this is not mandatory if you plan to use the data within your existing working environment. 

# based on saaWeb package by N. Komick
# Feb 2024 / updated Nov 2025



# Install packages if you haven't already ------------------
# install.packages("here")
# install.packages("remotes") 
  # remotes::install_git("https://github.com/Pacific-salmon-assess/saaWeb") 



# ============================ 1. DEFINE FUNCTION ============================
# This function will be used to access any data that are stored in "NuSEDS" and accessible through this extractor: https://pac-salmon.test.dfo-mpo.gc.ca/nuseds.query/#/

runNuSEDSQuery <- function(query_doc, config_file = "saaWeb.config", user_name = Sys.getenv("username"), password = NULL) 
{
  config_list <- saaWeb:::loadConfigFile(config_file)
  extractor_usage_url <- config_list$NusedsExtractorUsageUrl
  extractor_query_url <- config_list$NusedsExtractorQueryUrl
  query_result <- saaWeb:::runExtractorQuery(query_doc, extractor_usage_url, 
                                             extractor_query_url, user_name, password)
  return(query_result)
}


# ============================ 2. EXTRACT ESCAPEMENT DATA ============================
# This is where the above function is applied to actually pull the data. Note it requires a customised .json query document 
# Here I use the here() package to define where the query document is located. 
nuseds_data_extracted <- runNuSEDSQuery(query_doc = here::here("NuSEDS", "example_escapement_query_doc.json"),                                          # this line can be replaced with any URL to direct R to find the .json query document of choice. See other example for age query doc.
                                        config_file = "//ENT.dfo-mpo.ca/DFO-MPO/GROUP/PAC/PBS/Operations/SCA/SCD_Stad/saaWeb.config") #%>%              # can be changed to point to any URL where your config file is 
  # mutate(across(c(`Analysis Year`, `Max Estimate`:`Natural Adult Spawners`, `Other Adults Removals`:`Total Jack Return River`), as.numeric)) %>%      # the following parts below are suggestions for formatting to make it more R friendly but are not required 
  # mutate(`Total Adult Return River` = case_when(is.na(`Total Adult Return River`) ~ `Max Estimate`,
  #                                               TRUE ~ `Total Adult Return River`),
  #        `Adult Broodstock Removals` = case_when(is.na(`Adult Broodstock Removals`) ~ `Total Broodstock Removals`,
  #                                                TRUE ~ `Adult Broodstock Removals`)) %>%
  # pivot_longer(cols=c("Max Estimate":"Unspecified Return", "Other Removals":"Natural Adult Spawners", "Other Adults Removals":"Total Jack Return River"),
  #              names_to = "est_type", values_to = "estimate") %>%
  # rename(waterbody_name=`Waterbody Name`,
  #        year=`Analysis Year`) %>%
  # mutate(source="NuSEDS")


# Repeat this ^ again if you want to dump age data, just point "query_doc =" to the age query doc instead. You may want to rename the object "nuseds_data_extracted" to be more informative depending on what you are dumping.


# ============================ 3: EXPORT ============================
# Suggested code below to export the data. Obviously sub in your own URL, and if you changed the object name from "nuseds_data_extracted"

# Export to github repo ------------------------
writexl::write_xlsx(x = nuseds_data_extracted, 
                    path = "my/URL/of/choice/to/save/the/data.xlsx")

