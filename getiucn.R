# https://www.ucsbtidytuesday.com/post/2020-05-12-gordon-blasco-api/

setwd("/your/folder")

# List of required packages
packages <- c("rredlist", "tidyverse")

# Check if packages are already installed
# If not installed, install them
for (package in packages) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package)
  }
}

# Load the installed packages
library(rredlist)
library(tidyverse)

specieslist <- read_excel("redlist24424.xlsx")
Sys.setenv(IUCN_KEY = "738ec05f9a360cb2df71d013e7910017a8e9c28f120bf864bbb4f38b652914db")
apikey <- Sys.getenv("IUCN_KEY")

roughresults <- specieslist %>%
	mutate(iucn_pull = map(scientificName, rl_search, key = apikey))
	
results_clean <- roughresults %>%
	mutate(category = map_chr(iucn_pull, function(x) ifelse(is.null(pluck(x, "result", "category")), 
    "NA", pluck(x, "result", "category")))) %>%
	select(scientificName, category)

write.csv(results_clean, "results_clean.csv")

#write roughresults
#yaml::write_yaml(roughresults, "listall.yaml")	