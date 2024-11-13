library(dplyr)
library(tidyr)
library(stringr)
library(rvest)
library(lubridate)

aaa_nv <- read_html("https://gasprices.aaa.com/?state=NV")

gas_nv <- aaa_nv %>% html_nodes(".table-mob tr:nth-child(1) td") %>%
  html_text()

gas_df <- data.frame(gas_nv)

gas_df <- gas_df %>% 
  mutate(key = rep(c('Price', 'Regular', 'Mid', 'Premium', 'Diesel'), n() / 5), 
         id = cumsum(key == 'Price')) %>% 
  spread(key, gas_nv) %>% 
  select(id, Regular, Mid, Premium, Diesel) 

gas_df$id[which(gas_df$id == "1")] <- "Nevada"
gas_df$id[which(gas_df$id == "2")] <- "Reno"
gas_df$id[which(gas_df$id == "3")] <- "Las Vegas"


#Pivot data long
gas_df <- gas_df %>%
  pivot_longer(
    cols = c(2,3,4,5), # Select columns to pivot longer by index
    names_to = "Gas_Type",
    values_to = "Price")

#Add a date columm
gas_df <- gas_df %>% 
  mutate(Scrape_Date = Sys.Date())

##
#Make a backup of the full scrape

sys <- format(Sys.time(), "%Y_%m_%d")

sys_path <- paste0("data/NV_", sys, ".csv", collapse = NULL)

write.csv(gas_df, file=sys_path,row.names=FALSE)
