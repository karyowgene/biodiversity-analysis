# https://www.ucsbtidytuesday.com/post/2020-05-12-gordon-blasco-api/

setwd("/your/folder")

# List of required packages
packages <- c("rredlist", "tidyverse", "ggplot2")

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
library(ggplot2)

specieslist <- read_excel("redlist24424.xlsx")
Sys.setenv(IUCN_KEY = "inputkey")
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

df <- read.csv("results_clean.csv")

# Count the occurrences of each category
category_counts <- table(df$category)

# Convert the table to a data frame
category_df <- as.data.frame(category_counts)
names(category_df) <- c("Category", "Count")

# Plot the bar chart
hbar_chart <- ggplot(category_df, aes(x = Category, y = Count, fill = Category)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Count), position = position_stack(vjust = 0.5), size = 6, color = "black", fontface = "bold") +
  labs(title = "Category Distribution") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "none", 
        axis.text.x = element_text(angle = 45, hjust = 1, color = "black", size = 12, face = "bold"),
        axis.text.y = element_text(color = "black", size = 12, face = "bold"),
        axis.title.x = element_text(color = "black", size = 14, face = "bold"),
        axis.title.y = element_text(color = "black", size = 14, face = "bold"),
        plot.title = element_text(color = "black", size = 16, face = "bold"))

#################percentages

# Calculate percentages
#category_df$Percent <- round(category_df$Count / sum(category_df$Count) * 100, 1)

# Plot the barplot with percentages
#bar_chart <- ggplot(category_df, aes(x = Category, y = Count, fill = Category)) +
#  geom_bar(stat = "identity") +
#  geom_text(aes(label = paste0(Percent, "%")), position = position_stack(vjust = 0.5), size = 6, color = "black", fontface = "bold") +
#  labs(title = "Category Distribution") +
#  theme_minimal(base_size = 14) +
#  theme(legend.position = "none", 
#  	axis.text.x = element_text(angle = 45, hjust = 1, color = "black", size = 12, face = "bold"),
#  	axis.text.y = element_text(color = "black", size = 12, face = "bold"),
#  	axis.title.x = element_text(color = "black", size = 14, face = "bold"),
#  	axis.title.y = element_text(color = "black", size = 14, face = "bold"),
#  	plot.title = element_text(color = "black", size = 16, face = "bold"))
# Save the bar chart as a PDF file
ggsave("bar_chart.pdf", plot = bar_chart)